using rdoappClass;
using System.Collections.Generic;
using System.Linq;

namespace rdoappProject.Api.Models
{
    public class MunicipioModel
    {
        internal static List<MunicipioViewModel> ListaMunicipio(int idUF)
        {
            rdoappEntities context = new rdoappEntities();

            List<MunicipioViewModel> ListaMunicipio = new List<MunicipioViewModel>();

            context.municipio.Where(mun => mun.mun_id_uf == idUF).ToList().ForEach(mun =>
            ListaMunicipio.Add(new MunicipioViewModel
            {
                idMunicipio = mun.mun_id_municipio,
                Municipio = mun.mun_ds_municipio,
                UF = mun.uf.ufe_ds_sigla
            }));

            return ListaMunicipio;
        }

        internal static List<MunicipioViewModel> ListaMunicipioConvidada(int idUF)
        {
            rdoappEntities context = new rdoappEntities();

            List<MunicipioViewModel> ListaMunicipio = new List<MunicipioViewModel>();

            context.municipio.Where(mun => mun.mun_id_uf == idUF).ToList().ForEach(mun =>
            ListaMunicipio.Add(new MunicipioViewModel
            {
                idMunicipio = mun.mun_id_municipio,
                Municipio = mun.mun_ds_municipio,
                UF = mun.uf.ufe_ds_sigla
            }));

            return ListaMunicipio;
        }

        public static MunicipioViewModel ObterRegistro(int param)
        {
            rdoappEntities context = new rdoappEntities();

            municipio m = context.municipio.Where(mun => mun.mun_id_municipio == param).FirstOrDefault() ?? new municipio();
            MunicipioViewModel municipio = new MunicipioViewModel();

            municipio.idMunicipio = m.mun_id_municipio;
            municipio.Municipio = m.mun_ds_municipio;
            municipio.UF = m.uf == null ? "" : m.uf.ufe_ds_sigla;

            return municipio;
        }

        internal static object ListaUF()
        {
            rdoappEntities context = new rdoappEntities();

            List<object> ListaUF = new List<object>();

            context.uf.OrderBy(u => u.ufe_ds_sigla).ToList().ForEach(u =>
            ListaUF.Add(new
            {
                idUF = u.ufe_id_uf,
                UF = u.ufe_ds_sigla
            }));

            return ListaUF;
        }

        internal static object ListaUFConvidada()
        {
            rdoappEntities context = new rdoappEntities();

            List<object> ListaUF = new List<object>();
            ListaUF.Add(new { idUF = 0, UF = "Selecione uma UF" });

            context.uf.OrderBy(u => u.ufe_ds_sigla).ToList().ForEach(u =>
            ListaUF.Add(new
            {
                idUF = u.ufe_id_uf,
                UF = u.ufe_ds_sigla
            }));

            return ListaUF;
        }
    }

    public class MunicipioViewModel
    {
        public int idMunicipio { get; set; }
        public string Municipio { get; set; }
        public string UF { get; set; }

    }
}