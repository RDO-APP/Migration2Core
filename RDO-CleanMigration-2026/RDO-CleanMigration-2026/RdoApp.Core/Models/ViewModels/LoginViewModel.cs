using System.Collections.Generic;

namespace RdoApp.Core.Models.ViewModels
{
    /// <summary>
    /// Login response ViewModel - EXACT COPY from legacy code
    /// </summary>
    public class LoginViewModel
    {
        public LoginViewModel()
        {
            Routes = new List<RouteViewModel>();
            Menu = new MenuViewModel();
        }

        public UsuarioViewModel Usuario { get; set; }
        public List<RouteViewModel> Routes { get; set; }
        public MenuViewModel Menu { get; set; }
        public ObraColaboradorViewModel ObraColaborador { get; set; }
        public ObraViewModel Obra { get; set; }
    }

    public class UsuarioViewModel
    {
        public UsuarioViewModel()
        {
            Grupo = new GrupoViewModel();
        }

        public long Id { get; set; }
        public string NomeUsuario { get; set; }
        public string Email { get; set; }
        public string Senha { get; set; }
        public long? IdGrupo { get; set; }
        public long? Status { get; set; }
        public long? StatusAlterarSenha { get; set; }

        public virtual GrupoViewModel Grupo { get; set; }
    }

    public class RouteViewModel
    {
        public RouteViewModel()
        {
            Permissions = new List<string>();
        }

        public string Name { get; set; }
        public string Path { get; set; }
        public List<string> Permissions { get; set; }
    }

    public class MenuViewModel
    {
        public MenuViewModel()
        {
            ListaPagina = new List<PaginaViewModel>();
        }

        public long? Id { get; set; }
        public string Titulo { get; set; }
        public List<PaginaViewModel> ListaPagina { get; set; }
    }

    public class PaginaViewModel
    {
        public PaginaViewModel()
        {
            Paginas = new List<PaginaViewModel>();
        }

        public int Id { get; set; }
        public string Titulo { get; set; }
        public string Caminho { get; set; }
        public string CssClass { get; set; }
        public List<PaginaViewModel> Paginas { get; set; }
    }

    public class GrupoViewModel
    {
        public long Id { get; set; }
        public string Nome { get; set; }
    }

    public class ObraColaboradorViewModel
    {
        public long IdObraColaborador { get; set; }
        public string NomeObra { get; set; }
        public string NomeColaborador { get; set; }
        public long IdObra { get; set; }
        public long IdColaborador { get; set; }
        public long? IdGrupo { get; set; }
        public long? IdCargo { get; set; }
        public string ContratanteContratada { get; set; }
        public DateTime DataContratacao { get; set; }
        public string TipoLicencaColaboradorGrupo { get; set; }
        public int IdLicenca { get; set; }
    }

    public class ObraViewModel
    {
        public long IdObra { get; set; }
        public string Descricao { get; set; }
        public long idDono { get; set; }
        public long idContratante { get; set; }
        public long idContratada { get; set; }
        public string DataFim { get; set; }
        public bool ObraFinalizada { get; set; }
        public long idColaborador { get; set; }
    }
}
