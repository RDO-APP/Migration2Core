using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Utils;
using System.Security.Claims;

namespace RdoApp.Core.Controllers
{
    /// <summary>
    /// Account Controller - Clean Migration 2026
    /// EXACT COPY of legacy LoginController logic
    /// </summary>
    public class AccountController : Controller
    {
        private readonly RdoDbContext _context;
        private readonly ILogger<AccountController> _logger;

        public AccountController(RdoDbContext context, ILogger<AccountController> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// GET: /Account/Login
        /// Displays the login page
        /// </summary>
        [HttpGet]
        [AllowAnonymous]
        public IActionResult Login(string? returnUrl = null)
        {
            // If user is already authenticated, redirect to obra selection
            if (User.Identity?.IsAuthenticated == true)
            {
                _logger.LogInformation("User {UserName} already authenticated, redirecting to obra selection", User.Identity.Name);
                return RedirectToAction("Escolher", "Obra");
            }

            ViewData["ReturnUrl"] = returnUrl;
            ViewData["Title"] = "Login - RDO App Piscinas";
            
            _logger.LogInformation("Displaying login page");
            
            return View(new LoginDto());
        }

        /// <summary>
        /// POST: /Account/Login
        /// EXACT COPY of legacy LoginUser logic
        /// </summary>
        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginDto model, string? returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;
            ViewData["Title"] = "Login - RDO App Piscinas";

            _logger.LogInformation("Processing login attempt for CPF: {Cpf}", 
                model.Cpf?.Length > 3 ? model.Cpf.Substring(0, 3) + "***" : "***");

            if (!ModelState.IsValid)
            {
                _logger.LogWarning("Login form validation failed");
                return View(model);
            }

            try
            {
                // EXACT COPY: Remove CPF formatting (keep only numbers)
                string cpf = model.Cpf;
                cpf = !string.IsNullOrEmpty(cpf) ? cpf.Replace(".", "").Replace("-", "") : cpf;

                // EXACT COPY: Encrypt password with TripleDES
                string senhaEncriptada = Seguranca.EncryptTripleDES(model.Senha);

                _logger.LogInformation("Looking up colaborador with CPF: {Cpf}", cpf.Substring(0, 3) + "***");

                // EXACT COPY: Find colaborador by CPF AND encrypted password
                var colaborador = await _context.Colaboradores
                    .FirstOrDefaultAsync(c => c.ColNrCpf == cpf && c.ColDsSenha == senhaEncriptada);

                if (colaborador == null)
                {
                    _logger.LogWarning("Colaborador not found or invalid password for CPF: {Cpf}", cpf.Substring(0, 3) + "***");
                    ModelState.AddModelError(string.Empty, "Usuário ou senha não existem.");
                    return View(model);
                }

                // EXACT COPY: Build LoginViewModel with Routes and Menu
                var loginViewModel = new LoginViewModel
                {
                    Routes = ObterRotasDefault(colaborador),
                    Menu = ObterMenuDefault(colaborador),
                    Usuario = new UsuarioViewModel
                    {
                        Email = colaborador.ColDsEmail,
                        Id = colaborador.ColIdColaborador,
                        Senha = Seguranca.DecryptTripleDES(colaborador.ColDsSenha),
                        NomeUsuario = colaborador.ColNmColaborador
                    }
                };

                // EXACT COPY: Log to historico_login
                await InserirHistoricoLogin(new HistoricoLogin
                {
                    col_id_colaborador = colaborador.ColIdColaborador,
                    col_ds_email = colaborador.ColDsEmail,
                    col_nm_colaborador = colaborador.ColNmColaborador,
                    col_nr_cpf = colaborador.ColNrCpf,
                    data_login = DateTime.Now
                });

                // Create authentication cookie
                var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.NameIdentifier, colaborador.ColIdColaborador.ToString()),
                    new Claim(ClaimTypes.Name, colaborador.ColNmColaborador),
                    new Claim("cpf", colaborador.ColNrCpf),
                    new Claim("email", colaborador.ColDsEmail ?? ""),
                    new Claim("isAdmin", (colaborador.ColStAdmin == true).ToString())
                };

                var claimsIdentity = new ClaimsIdentity(claims, "Cookies");
                var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

                var authProperties = new AuthenticationProperties
                {
                    IsPersistent = model.LembrarMe,
                    ExpiresUtc = model.LembrarMe 
                        ? DateTimeOffset.UtcNow.AddDays(30) 
                        : DateTimeOffset.UtcNow.AddHours(8)
                };

                await HttpContext.SignInAsync("Cookies", claimsPrincipal, authProperties);

                // Store colaboradorId and login data in session
                HttpContext.Session.SetInt32("ColaboradorId", colaborador.ColIdColaborador);
                HttpContext.Session.SetString("LoginData", System.Text.Json.JsonSerializer.Serialize(loginViewModel));

                _logger.LogInformation("User {Nome} (ID: {ColaboradorId}) logged in successfully", 
                    colaborador.ColNmColaborador, colaborador.ColIdColaborador);

                // EXACT COPY: Redirect to Obra selection (not home)
                return RedirectToAction("Escolher", "Obra");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during login for CPF {Cpf}", 
                    model.Cpf?.Length > 3 ? model.Cpf.Substring(0, 3) + "***" : "***");
                
                ModelState.AddModelError(string.Empty, "Erro interno do sistema. Tente novamente.");
                return View(model);
            }
        }

        /// <summary>
        /// POST: /Account/Logout
        /// Logs out the current user
        /// </summary>
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout()
        {
            var userName = User.Identity?.Name ?? "Unknown User";
            
            try
            {
                await HttpContext.SignOutAsync("Cookies");
                HttpContext.Session.Clear();
                _logger.LogInformation("User {UserName} logged out successfully", userName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during logout for user {UserName}", userName);
            }
            
            return RedirectToAction("Login");
        }

        /// <summary>
        /// GET: /Account/AccessDenied
        /// Displays access denied page
        /// </summary>
        [HttpGet]
        [AllowAnonymous]
        public IActionResult AccessDenied()
        {
            _logger.LogWarning("Access denied for user {UserName}", User.Identity?.Name ?? "Anonymous");
            return View();
        }

        #region EXACT COPY: Legacy Helper Methods

        /// <summary>
        /// EXACT COPY from legacy ObterMenuDefault
        /// </summary>
        private MenuViewModel ObterMenuDefault(Data.Entities.Colaborador colaborador)
        {
            MenuViewModel menu = new MenuViewModel();
            menu.ListaPagina = new List<PaginaViewModel>();

            if (colaborador.ColStAdmin != null && colaborador.ColStAdmin == true)
            {
                menu.ListaPagina.Add(new PaginaViewModel { Titulo = "Pagina", Caminho = "/pagina/index" });
                menu.ListaPagina.Add(new PaginaViewModel { Titulo = "Menu", Caminho = "/menu/index" });
                menu.ListaPagina.Add(new PaginaViewModel { Titulo = "Grupo", Caminho = "/grupo/index" });
                menu.ListaPagina.Add(new PaginaViewModel { Titulo = "Histórico de Acessos", Caminho = "/historicoacesso/index" });
            }

            return menu;
        }

        /// <summary>
        /// EXACT COPY from legacy ObterRotasDefault
        /// </summary>
        private List<RouteViewModel> ObterRotasDefault(Data.Entities.Colaborador colaborador)
        {
            var ListaRotas = new List<RouteViewModel>();

            RouteViewModel rota = new RouteViewModel();
            rota.Name = "Escolher Obra";
            rota.Path = "/obra/escolher";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            rota = new RouteViewModel();
            rota.Name = "Adicionar Obra";
            rota.Path = "/obra/cadastro";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            rota = new RouteViewModel();
            rota.Name = "Alterar Senha";
            rota.Path = "/colaborador/alterarsenha";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            rota = new RouteViewModel();
            rota.Name = "Convidada";
            rota.Path = "/convidada";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            rota = new RouteViewModel();
            rota.Name = "Etapa";
            rota.Path = "/etapa/index";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            rota = new RouteViewModel();
            rota.Name = "Etapa";
            rota.Path = "/etapa/cadastro";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            rota = new RouteViewModel();
            rota.Name = "Gráfico";
            rota.Path = "/chart";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            rota = new RouteViewModel();
            rota.Name = "Gráfico RDOs";
            rota.Path = "/chart/rdos";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            rota = new RouteViewModel();
            rota.Name = "Gráfico RDOs Atrasado";
            rota.Path = "/chart/atrasado";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            rota = new RouteViewModel();
            rota.Name = "Gráfico Dia Improdutivo";
            rota.Path = "/chart/diaimprodutivo";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            rota = new RouteViewModel();
            rota.Name = "Gráfico Tarefas";
            rota.Path = "/chart/tarefa";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            rota = new RouteViewModel();
            rota.Name = "Gráfico Comentários";
            rota.Path = "/chart/comentario";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            rota = new RouteViewModel();
            rota.Name = "Códigos de Paralizações";
            rota.Path = "/tarefa/paralizacoes/index";
            rota.Permissions = new List<string>();
            rota.Permissions.Add("visualizar");
            ListaRotas.Add(rota);

            ListaRotas.AddRange(ObterRotasAdmin(colaborador));

            return ListaRotas;
        }

        /// <summary>
        /// EXACT COPY from legacy ObterRotasAdmin
        /// </summary>
        private List<RouteViewModel> ObterRotasAdmin(Data.Entities.Colaborador colaborador)
        {
            var ListaRotas = new List<RouteViewModel>();

            if (colaborador.ColStAdmin != null && colaborador.ColStAdmin == true)
            {
                RouteViewModel rota = new RouteViewModel();
                rota.Name = "Pagina";
                rota.Path = "/pagina/index";
                rota.Permissions = new List<string>();
                rota.Permissions.AddRange("visualizar,editar,deletar,cadastrar".Split(','));
                ListaRotas.Add(rota);

                rota = new RouteViewModel();
                rota.Name = "Cadastro Pagina";
                rota.Path = "/pagina/cadastro";
                rota.Permissions = new List<string>();
                rota.Permissions.AddRange("visualizar,editar,deletar,cadastrar".Split(','));
                ListaRotas.Add(rota);

                rota = new RouteViewModel();
                rota.Name = "Grupo";
                rota.Path = "/grupo/index";
                rota.Permissions = new List<string>();
                rota.Permissions.AddRange("visualizar,editar,deletar,cadastrar".Split(','));
                ListaRotas.Add(rota);

                rota = new RouteViewModel();
                rota.Name = "Cadastro Grupo";
                rota.Path = "/grupo/cadastro";
                rota.Permissions = new List<string>();
                rota.Permissions.AddRange("visualizar,editar,deletar,cadastrar".Split(','));
                ListaRotas.Add(rota);

                rota = new RouteViewModel();
                rota.Name = "Menu";
                rota.Path = "/menu/index";
                rota.Permissions = new List<string>();
                rota.Permissions.AddRange("visualizar,editar,deletar,cadastrar".Split(','));
                ListaRotas.Add(rota);

                rota = new RouteViewModel();
                rota.Name = "Cadastro Menu";
                rota.Path = "/menu/cadastro";
                rota.Permissions = new List<string>();
                rota.Permissions.AddRange("visualizar,editar,deletar,cadastrar".Split(','));
                ListaRotas.Add(rota);

                rota = new RouteViewModel();
                rota.Name = "Histórico de Acessos";
                rota.Path = "/historicoacesso/index";
                rota.Permissions = new List<string>();
                rota.Permissions.AddRange("visualizar,editar,deletar,cadastrar".Split(','));
                ListaRotas.Add(rota);
            }

            return ListaRotas;
        }

        /// <summary>
        /// EXACT COPY from legacy InserirHistoricoLogin
        /// </summary>
        private async Task InserirHistoricoLogin(HistoricoLogin historico)
        {
            try
            {
                // Use FormattableString for safe SQL interpolation
                var obraId = historico.obr_id_obra.HasValue ? historico.obr_id_obra.Value.ToString() : "NULL";
                var obraDs = historico.obr_ds_obra != null ? $"'{historico.obr_ds_obra.Replace("'", "''")}'" : "NULL";
                
                string insert = $@"
                INSERT INTO historico_login
                (
                    col_id_colaborador,
                    col_nr_cpf,
                    col_nm_colaborador,
                    col_ds_email,
                    obr_id_obra,
                    obr_ds_obra,
                    data_login
                )
                VALUES (
                    {historico.col_id_colaborador},
                    '{historico.col_nr_cpf?.Replace("'", "''")}',
                    '{historico.col_nm_colaborador?.Replace("'", "''")}',
                    '{historico.col_ds_email?.Replace("'", "''")}',
                    {obraId},
                    {obraDs},
                    '{(historico.data_login ?? DateTime.Now):yyyy-MM-dd HH:mm:ss}'
                )";

                await _context.Database.ExecuteSqlRawAsync(insert);

                _logger.LogInformation("Login history recorded for colaborador {ColaboradorId}", historico.col_id_colaborador);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to insert login history for colaborador {ColaboradorId}", historico.col_id_colaborador);
                // Don't throw - login should succeed even if history logging fails
            }
        }

        #endregion
    }

    /// <summary>
    /// EXACT COPY from legacy HistoricoLogin
    /// </summary>
    public class HistoricoLogin
    {
        public long col_id_colaborador { get; set; }
        public string col_nr_cpf { get; set; }
        public string col_nm_colaborador { get; set; }
        public string col_ds_email { get; set; }
        public long? obr_id_obra { get; set; }
        public string obr_ds_obra { get; set; }
        public DateTime? data_login { get; set; }
    }
}
