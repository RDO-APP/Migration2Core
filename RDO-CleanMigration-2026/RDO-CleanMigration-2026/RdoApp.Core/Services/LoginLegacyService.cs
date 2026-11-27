using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Controllers;
using RdoApp.Core.Data;
using RdoApp.Core.Models.ViewModels;

namespace RdoApp.Core.Services;

/// <summary>
/// Paridade legado LoginUser: view model de sessao, menu, rotas e historico_login.
/// Compartilhado entre o login Web (AccountController) e a API mobile (api/login/LoginUser).
/// </summary>
public sealed class LoginLegacyService
{
    private readonly RdoDbContext _context;
    private readonly ILogger<LoginLegacyService> _logger;

    public LoginLegacyService(RdoDbContext context, ILogger<LoginLegacyService> logger)
    {
        _context = context;
        _logger = logger;
    }
        public LoginViewModel BuildLoginViewModel(Data.Entities.Colaborador colaborador)
        {
            return new LoginViewModel
            {
                Routes = ObterRotasDefault(colaborador),
                Menu = ObterMenuDefault(colaborador),
                Usuario = new UsuarioViewModel
                {
                    Email = colaborador.ColDsEmail,
                    Id = colaborador.ColIdColaborador,
                    Senha = string.Empty,
                    NomeUsuario = colaborador.ColNmColaborador
                }
            };
        }


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
        public async Task InserirHistoricoLogin(HistoricoLogin historico)
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

}
