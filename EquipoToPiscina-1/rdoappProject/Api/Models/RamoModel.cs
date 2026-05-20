using rdoappClass;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace rdoappProject.Api.Models
{
    public class RamoModel
    {
        public static List<RamoViewModel> Lista()
        {
            rdoappEntities context = new rdoappEntities();

            IQueryable<ramo> query = context.Set<ramo>();

            List<RamoViewModel> Lista = new List<RamoViewModel>();

            query.ToList().ForEach(ram => Lista.Add(new RamoViewModel
            {
                Id = ram.ram_id_ramo,
                Nome = ram.ram_ds_ramo

            }));

            return Lista.OrderBy(x => x.Id).ToList();
        }

        public static bool Remove(dynamic param)
        {
            try
            {
                int? idRamo = param.idRamo;
                rdoappEntities context = new rdoappEntities();
                string codigoRamo = param.codigoRamo;
                context.ramo.Remove(context.ramo.FirstOrDefault(ram => ram.ram_id_ramo == idRamo || ram.ram_id_ramo_loja == codigoRamo));
                return context.SaveChanges() > 0;
            }
            catch
            {
                throw new Exception("Não foi possível remover o Ramo. Existem registros dependentes");
            }
        }

        public static bool Atualizar(dynamic param)
        {
            try
            {
                int? idRamo = param.idRamo;
                string codigoRamo = param.codigoRamo;
                string descricao = param.descricao;

                rdoappEntities context = new rdoappEntities();
                ramo objRamo = context.ramo.FirstOrDefault(ram => ram.ram_id_ramo == idRamo || ram.ram_id_ramo_loja == codigoRamo) ?? new ramo();

                objRamo.ram_ds_ramo = descricao;
                if (!string.IsNullOrEmpty(codigoRamo))
                    objRamo.ram_id_ramo_loja = codigoRamo;

                if (objRamo.ram_id_ramo > 0)
                {
                    context.ramo.Attach(objRamo);
                    context.Entry(objRamo).State = System.Data.Entity.EntityState.Modified;
                }
                else
                {
                    context.ramo.Add(objRamo);
                }

                return context.SaveChanges() > 0;
            }
            catch (Exception e)
            {
                throw new Exception("Não foi possível atualizar o Ramo, tente novamente");
            }
        }
    }

    public class RamoViewModel
    {
        public long Id { get; set; }
        public string Nome { get; set; }
    }
}