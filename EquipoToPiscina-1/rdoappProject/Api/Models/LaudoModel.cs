using Microsoft.Reporting.WebForms;
using rdoappClass;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Hosting;

namespace rdoappProject.Api.Models
{
    public class LaudoModel
    {
        private static CultureInfo cultureInfo = new CultureInfo("pt-BR");

        public static List<LaudoViewModel> DashboardGrafico(dynamic param)
        {
            int idObra = param.unidadeEscolar ?? 0;
            rdoappEntities context = new rdoappEntities();
            List<laudo> query = context.Set<laudo>().ToList();

            if (idObra != 0)
                query = query.Where(laudo => laudo.lau_id_obra == idObra).ToList();

            DateTime dataInicial = String.IsNullOrEmpty(Convert.ToString(param.dataInicial)) ? DateTime.MinValue : Convert.ToDateTime(Convert.ToString(param.dataInicial));
            DateTime dataFinal = String.IsNullOrEmpty(Convert.ToString(param.dataFinal)) ? DateTime.MinValue : Convert.ToDateTime(Convert.ToString(param.dataFinal));

            if (dataInicial > DateTime.MinValue)
            {
                query = query.Where(laudo => laudo.lau_dt_laudo >= dataInicial).ToList();
            }
            if (dataFinal > DateTime.MinValue)
            {
                query = query.Where(laudo => laudo.lau_dt_laudo <= dataFinal).ToList();
            }

            List<LaudoViewModel> Lista = new List<LaudoViewModel>();
            query.OrderByDescending(x => x.lau_id_laudo).ToList().ForEach(laudo => Lista.Add(new LaudoViewModel
            {
                lau_dt_laudo = laudo.lau_dt_laudo == null || laudo.lau_dt_laudo == DateTime.MinValue ? "" : laudo.lau_dt_laudo.Date.ToString().Substring(0, 10),
                lau_id_laudo = laudo.lau_id_laudo,
                lau_id_status = laudo.lau_id_status,
                lau_ds_comentario_assinatura = laudo.lau_ds_comentario_assinatura,


                lau_tp_nivel_cloro = (bool)laudo.lau_tp_nivel_cloro,
                lau_tp_ph = (bool)laudo.lau_tp_ph,
                lau_tp_limpidez = (bool)laudo.lau_tp_limpidez,
                lau_tp_superficie = (bool)laudo.lau_tp_superficie,
                lau_tp_fundo = (bool)laudo.lau_tp_fundo,
                lau_tp_nivel_cloro_2 = (bool)laudo.lau_tp_nivel_cloro_2,
                lau_tp_nivel_bacterias = (bool)laudo.lau_tp_nivel_bacterias,
                lau_tp_nivel_proliferacao = (bool)laudo.lau_tp_nivel_proliferacao,

                DiaDaSemana = cultureInfo.DateTimeFormat.DayNames[(int)laudo.lau_dt_laudo.Date.DayOfWeek],
                DescricaoStatus = obterStatusRdo(context, laudo.lau_id_status).str_ds_status
            }));

            return Lista;
        }

        private static status_rdo obterStatusRdo(rdoappEntities context, int idStatusRdo)
        {
            status_rdo statusRdo = context.status_rdo.FirstOrDefault(x => x.str_id_status == idStatusRdo);
            if (statusRdo == null)
            {
                throw new Exception("Status RDO não encontrado.");
            }
            return statusRdo;
        }

        public static List<LaudoViewModel> Lista(dynamic param)
        {
            int idObra = param.idObra ?? 0;
            rdoappEntities context = new rdoappEntities();
            List<laudo> query = context.Set<laudo>().ToList();

            query = query.Where(rdo => rdo.lau_id_obra == idObra).ToList();

            int statusRdo = param.statusRdo ?? 0;
            DateTime dataInicial = String.IsNullOrEmpty(Convert.ToString(param.dataInicial)) ? DateTime.MinValue : Convert.ToDateTime(Convert.ToString(param.dataInicial));
            DateTime dataFinal = String.IsNullOrEmpty(Convert.ToString(param.dataFinal)) ? DateTime.MinValue : Convert.ToDateTime(Convert.ToString(param.dataFinal));

            if (statusRdo > 0)
            {
                query = query.Where(rdo => rdo.lau_id_status == statusRdo).ToList();
            }
            if (dataInicial > DateTime.MinValue)
            {
                query = query.Where(rdo => rdo.lau_dt_laudo >= dataInicial).ToList();
            }
            if (dataFinal > DateTime.MinValue)
            {
                query = query.Where(rdo => rdo.lau_dt_laudo <= dataFinal).ToList();
            }

            List<LaudoViewModel> Lista = new List<LaudoViewModel>();
            query.OrderByDescending(x => x.lau_id_laudo).ToList().ForEach(laudo => Lista.Add(new LaudoViewModel
            {
                lau_dt_laudo = laudo.lau_dt_laudo == null || laudo.lau_dt_laudo == DateTime.MinValue ? "" : laudo.lau_dt_laudo.Date.ToString().Substring(0, 10),
                lau_id_laudo = laudo.lau_id_laudo,
                lau_id_status = laudo.lau_id_status,
                lau_ds_comentario_assinatura = laudo.lau_ds_comentario_assinatura,


                lau_tp_nivel_cloro = (bool)laudo.lau_tp_nivel_cloro,
                lau_tp_ph = (bool)laudo.lau_tp_ph,
                lau_tp_limpidez = (bool)laudo.lau_tp_limpidez,
                lau_tp_superficie = (bool)laudo.lau_tp_superficie,
                lau_tp_fundo = (bool)laudo.lau_tp_fundo,
                lau_tp_nivel_cloro_2 = (bool)laudo.lau_tp_nivel_cloro_2,
                lau_tp_nivel_bacterias = (bool)laudo.lau_tp_nivel_bacterias,
                lau_tp_nivel_proliferacao = (bool)laudo.lau_tp_nivel_proliferacao,

                DiaDaSemana = cultureInfo.DateTimeFormat.DayNames[(int)laudo.lau_dt_laudo.Date.DayOfWeek],
                DescricaoStatus = obterStatusRdo(context, laudo.lau_id_status).str_ds_status
            }));


            return Lista;
        }
        public static int ObterQuantidadeMaquinas(rdo objRdo)
        {
            int qtdMaquinas = 0;

            foreach (var tarefa in objRdo.rdo_tarefa)
            {
                qtdMaquinas += tarefa.tarefa.obra_tarefa_equipamento.Count;
            }

            return qtdMaquinas;
        }
        public static int ObterQuantidadeColaboradores(rdo objRdo)
        {
            int qtdColaboradores = 0;
            List<colaborador> colaboradores = new List<colaborador>();

            foreach (var tarefa in objRdo.rdo_tarefa)
            {
                tarefa.tarefa.obra_tarefa_colaborador.Select(otc => otc.obra_colaborador.colaborador).ToList().ForEach(otc => colaboradores.Add(otc));
            }
            qtdColaboradores = colaboradores.GroupBy(otc => otc.col_nm_colaborador).Count();
            return qtdColaboradores;
        }
        public static bool ExisteRdoPendente(dynamic param)
        {
            int idObra = param.idObra ?? 0;
            bool returnValue = false;
            string data = param.dataRdo.ToString();

            DateTime dataRdo = Convert.ToDateTime(data);
            DateTime dataRdoAnterior = dataRdo.AddDays(-1);
            rdoappEntities context = new rdoappEntities();
            rdo _rdo = context.rdo.Where(x => x.rdo_dt_rdo == dataRdoAnterior && x.rdo_id_obra == idObra).FirstOrDefault() ?? new rdo();
            obra _obra = context.obra.Where(x => x.obr_id_obra == idObra).FirstOrDefault() ?? new obra();
            if (_obra.obr_dt_inicio.Date == dataRdo.Date)
            {
                return false;
            }

            returnValue = _rdo.rdo_id_rdo > 0;
            return !returnValue;
        }

        public static LaudoViewModel Salvar(dynamic param)
        {
            rdoappEntities context = new rdoappEntities();

            if (string.IsNullOrEmpty(param.dataLaudo.ToString()))
            {
                throw new Exception("A data deve ser preenchida");
            }

            int idColaborador = param.idColaborador ?? 0;
            int idObra = param.idObra ?? 0;
            DateTime dataLaudo = Convert.ToDateTime(param.dataLaudo.ToString());
            obra _obra = context.obra.FirstOrDefault(x => x.obr_id_obra == idObra);

            if (_obra != null && dataLaudo < _obra.obr_dt_inicio)
            {
                throw new Exception("Não é possível gerar um laudo anterior a data inicial da unidade escolar.");
            }
            if (_obra != null && _obra.obr_dt_fim != null && _obra.obr_dt_fim != DateTime.MinValue && dataLaudo > _obra.obr_dt_fim)
            {
                throw new Exception("Não é possível gerar um RDO posterior a data final da obra.");
            }

            laudo _laudo = context.laudo.Where(x => x.lau_dt_laudo == dataLaudo && x.lau_id_obra == idObra).FirstOrDefault() ?? new laudo();

            if (_laudo.lau_id_laudo > 0 && obterStatusRdo(context, _laudo.lau_id_status) != null && (obterStatusRdo(context, _laudo.lau_id_status).str_ds_status.ToLower().Contains("assinado")))
            {
                throw new Exception("Não é possível sobrescrever um Laudo que já foi assinado.");
            }

            _laudo.lau_dt_laudo = Convert.ToDateTime(dataLaudo);
            _laudo.lau_id_status = 1;

            _laudo.lau_tp_nivel_cloro = param.nivelCloro == null ? false : param.nivelCloro;
            _laudo.lau_tp_ph = param.ph == null ? false : param.ph;
            _laudo.lau_tp_limpidez = param.limpidez == null ? false : param.limpidez;
            _laudo.lau_tp_superficie = param.superficie == null ? false : param.superficie;
            _laudo.lau_tp_fundo = param.fundo == null ? false : param.fundo;
            _laudo.lau_tp_nivel_cloro_2 = param.nivelCloro2 == null ? false : param.nivelCloro2;
            _laudo.lau_tp_nivel_bacterias = param.bacterias == null ? false : param.bacterias;
            _laudo.lau_tp_nivel_proliferacao = param.proliferacao == null ? false : param.proliferacao;

            _laudo.lau_ds_comentario_geracao = param.comentario;
            _laudo.lau_tp_comentario_geracao = param.tipoComentarioGeracao == 0 ? null : param.tipoComentarioGeracao == 1 ? "P" : "N";

            _laudo.lau_id_obra = idObra;
            _laudo.lau_dt_geracao = DateTime.Now;

            if (context.laudo.ToList().Any(x => x.lau_id_obra == idObra && x.lau_dt_laudo == _laudo.lau_dt_laudo))
            {
                context.laudo.Attach(_laudo);
                context.Entry(_laudo).State = System.Data.Entity.EntityState.Modified;
            }
            else
            {
                _laudo.lau_id_colaborador = idColaborador;
                context.laudo.Add(_laudo);
            }

            bool result = context.SaveChanges() > 0;
            if (param.listaImagens != null)
            {
                IncluirImagens(param.listaImagens, _laudo, context);
            }

            return PreencherViewModel(_laudo, param.listaImagens != null);
        }

        private static void IncluirImagens(dynamic listaImagems, laudo laudo, rdoappEntities context)
        {
            rdoappEntities rdoContext = new rdoappEntities();
            List<rdo_imagem> rdoImagens = rdoContext.rdo_imagem.Where(ri => ri.rim_id_rdo == laudo.lau_id_laudo).ToList();

            if (rdoImagens.Count > 0)
            {
                foreach (var item in rdoImagens)
                {
                    rdoContext.rdo_imagem.Remove(item);

                    imagem i = rdoContext.imagem.Find(item.rim_id_imagem);

                    rdoContext.imagem.Remove(i);
                }

                rdoContext.SaveChanges();
            }

            using (context = new rdoappEntities())
            {
                foreach (var item in listaImagems)
                {
                    SaveImages(item, context, laudo);

                    var _idImagem = context.imagem
                        .Where(x => x.ima_id_tarefa == laudo.lau_id_laudo)
                        .OrderByDescending(x => x.ima_id_imagem)
                        .Select(x => x.ima_id_imagem)
                        .FirstOrDefault();

                    var rDOImagem = new rdo_imagem();
                    rDOImagem.rim_id_rdo = laudo.lau_id_laudo;
                    rDOImagem.rim_id_imagem = _idImagem;

                    context.rdo_imagem.Add(rDOImagem);
                }

                context.SaveChanges();
            }
        }

        private static void SaveImages(dynamic item, rdoappEntities context, laudo entity)
        {
            var caminhoRelativo = "/uploads/tarefa/" + entity.lau_id_laudo;
            var caminhoAbsoluto = HostingEnvironment.ApplicationPhysicalPath + caminhoRelativo;
            if (!Directory.Exists(caminhoAbsoluto)) { Directory.CreateDirectory(caminhoAbsoluto); }

            string imagem = item.base64;
            byte[] Imagembytes = Convert.FromBase64String(imagem);
            var nomeArquivo = "/" + Guid.NewGuid().ToString("N") + ".png";
            var caminhoAbsolutoArquivo = caminhoAbsoluto + nomeArquivo;

            using (MemoryStream ms = new MemoryStream(Imagembytes))
            {
                using (Bitmap bm2 = new Bitmap(ms))
                {
                    Bitmap resized = new Bitmap(bm2, new Size(bm2.Width / 2, bm2.Height / 2));
                    ImageCodecInfo codec = ImageCodecInfo.GetImageEncoders().FirstOrDefault(enc => enc.MimeType == (string)item.filetype);
                    EncoderParameters imgParams = new EncoderParameters(1);
                    imgParams.Param = new[] { new EncoderParameter(Encoder.Quality, 0L) };

                    resized.Save(caminhoAbsolutoArquivo, codec, imgParams);

                    context.imagem.Add(new imagem
                    {
                        ima_ds_caminho = caminhoRelativo + nomeArquivo,
                        ima_dt_imagem = DateTime.Now,
                        ima_id_tarefa = entity.lau_id_laudo
                    });

                    context.SaveChanges();
                }
            }
        }

        public static LaudoViewModel PreencherViewModel(laudo _laudo, bool relatorioFotografico)
        {
            LaudoViewModel returnObj = new LaudoViewModel();
            returnObj.lau_id_laudo = _laudo.lau_id_laudo;
            returnObj.lau_id_obra = _laudo.lau_id_obra;
            returnObj.gerarRelatorioFotografico = relatorioFotografico;
            returnObj.lau_dt_laudo = _laudo.lau_dt_laudo.Date.ToString().Substring(0, 10);
            return returnObj;
        }
        public static byte[] GerarDocumentoRdo(int idRdo, bool gerarRelatorioFotografico = false)
        {
            rdoappEntities context = new rdoappEntities();
            laudo _rdo = context.laudo.FirstOrDefault(x => x.lau_id_laudo == idRdo);

            List<equipamento> listaEquipamentos = new List<equipamento>();
            List<tarefa> listaTarefas = new List<tarefa>();
            List<cargo> listaCargos = new List<cargo>();
            List<obra_tarefa_colaborador> listaTarefasColaboradores = new List<obra_tarefa_colaborador>();
            List<acidente> listaAcidentesAux = context.acidente.ToList() ?? new List<acidente>();
            List<acidente> listaAcidentes = new List<acidente>();

            listaTarefasColaboradores = listaTarefasColaboradores.Distinct().ToList();

            foreach (var item in listaTarefasColaboradores)
            {
                var cargo = ObterObraColaborador(item.otc_id_obra_colaborador).cargo;
                if (item.obra_colaborador.grupo.gru_nm_nome.Equals("Terceirizado"))
                    cargo.car_ds_cargo = $"{cargo.car_ds_cargo} (Terceirizado)";

                listaCargos.Add(cargo);
            }

            var cargosAgrupados = listaCargos.GroupBy(c => c.car_ds_cargo).
                     Select(group =>
                         new
                         {
                             DescricaoCargo = group.Key,
                             QuantidadeCargo = group.Count()
                         });

            listaEquipamentos = listaEquipamentos.Distinct().ToList();

            var equipamentosAgrupados = listaEquipamentos.GroupBy(e => e.equ_id_tipo_equipamento).
                     Select(group =>
                         new
                         {
                             DescricaoEquipamento = group.FirstOrDefault().tipo_equipamento.teq_nm_tipo_equipamento,
                             QuantidadeEquipamento = listaEquipamentos.Where(eq => eq.equ_id_tipo_equipamento == group.FirstOrDefault().tipo_equipamento.teq_id_tipo_equipamento).Count()
                         });


            DataTable dtCargosAgrupados = new DataTable();
            dtCargosAgrupados.Columns.Add("DescricaoCargo");
            dtCargosAgrupados.Columns.Add("QuantidadeCargo");

            cargosAgrupados = cargosAgrupados.OrderBy(o => o.DescricaoCargo);

            foreach (var item in cargosAgrupados)
            {
                dtCargosAgrupados.Rows.Add(item.DescricaoCargo, item.QuantidadeCargo);
            }


            DataTable dtEquipamentosAgrupados = new DataTable();
            dtEquipamentosAgrupados.Columns.Add("DescricaoEquipamento");
            dtEquipamentosAgrupados.Columns.Add("QuantidadeEquipamento");

            equipamentosAgrupados = equipamentosAgrupados.OrderBy(o => o.DescricaoEquipamento);
            foreach (var item in equipamentosAgrupados)
            {
                dtEquipamentosAgrupados.Rows.Add(item.DescricaoEquipamento, item.QuantidadeEquipamento);
            }


            DataTable dtTarefas = new DataTable();
            dtTarefas.Columns.Add("tar_ds_tarefa");
            dtTarefas.Columns.Add("tar_ds_comentario");
            dtTarefas.Columns.Add("tar_ds_status");
            dtTarefas.Columns.Add("tar_ds_etapa");

            foreach (var item in listaTarefas.OrderBy(o => o.status_tarefa.stt_id_status))
            {
                dtTarefas.Rows.Add(item.tar_ds_tarefa, item.tar_ds_comentario, item.status_tarefa.stt_ds_status, item.etapa.eta_ds_etapa);
            }

            DataTable dtClima = new DataTable();
            dtClima.Columns.Add("ClimaManha");
            dtClima.Columns.Add("ClimaTarde");
            dtClima.Columns.Add("ClimaNoite");
            dtClima.Columns.Add("ChuvaManha");
            dtClima.Columns.Add("ChuvaTarde");
            dtClima.Columns.Add("ChuvaNoite");

            DataTable dtAcidentes = new DataTable();
            dtAcidentes.Columns.Add("aci_ds_acidente");
            dtAcidentes.Columns.Add("aci_st_afastamento");

            DataTable dtItensLaudo = new DataTable();
            dtItensLaudo.Columns.Add("lau_tp_nivel_cloro");
            dtItensLaudo.Columns.Add("lau_tp_ph");
            dtItensLaudo.Columns.Add("lau_tp_limpidez");
            dtItensLaudo.Columns.Add("lau_tp_superficie");
            dtItensLaudo.Columns.Add("lau_tp_fundo");
            dtItensLaudo.Columns.Add("lau_tp_nivel_cloro_2");
            dtItensLaudo.Columns.Add("lau_tp_nivel_bacterias");
            dtItensLaudo.Columns.Add("lau_tp_nivel_proliferacao");

            var nivelCloro = _rdo.lau_tp_nivel_cloro == true ? "Sim" : "Não";
            var ph = _rdo.lau_tp_ph == true ? "Sim" : "Não";
            var limpidez = _rdo.lau_tp_limpidez == true ? "Sim" : "Não";
            var superficie = _rdo.lau_tp_superficie == true ? "Sim" : "Não";
            var fundo = _rdo.lau_tp_fundo == true ? "Sim" : "Não";
            var nivelCloro2 = _rdo.lau_tp_nivel_cloro_2 == true ? "Sim" : "Não";
            var bacterias = _rdo.lau_tp_nivel_bacterias == true ? "Sim" : "Não";
            var proliferacao = _rdo.lau_tp_nivel_bacterias == true ? "Sim" : "Não";

            dtItensLaudo.Rows.Add(nivelCloro, ph, limpidez, superficie, fundo, nivelCloro2, bacterias, proliferacao);

            DataTable dtAssinaturaContratante = new DataTable();
            dtAssinaturaContratante.Columns.Add("responsavel_assinatura");
            dtAssinaturaContratante.Columns.Add("cpf");
            dtAssinaturaContratante.Columns.Add("data_hora");
            dtAssinaturaContratante.Columns.Add("cargo");
            dtAssinaturaContratante.Columns.Add("ip");


            //_rdo
            assinatura_rdo assinaturaContratante = context.assinatura_rdo.FirstOrDefault(x => x.ass_id_rdo == _rdo.lau_id_laudo && x.obra_colaborador.grupo.gru_nm_nome.ToLower().Contains("contratante")) ?? new assinatura_rdo();
            if (assinaturaContratante.ass_id_obra_colaborador_assinante > 0)
            {
                dtAssinaturaContratante.Rows.Add(assinaturaContratante.obra_colaborador.colaborador.col_nm_colaborador, assinaturaContratante.obra_colaborador.colaborador.col_nr_cpf, assinaturaContratante.ass_dt_assinatura, assinaturaContratante.obra_colaborador.cargo.car_ds_cargo, assinaturaContratante.ass_ds_ip);
            }
            else
            {
                dtAssinaturaContratante.Rows.Add("Não assinado", "Não assinado", "Não assinado", "Não assinado");
            }




            DataTable dtAssinaturaContratada = new DataTable();
            dtAssinaturaContratada.Columns.Add("responsavel_assinatura");
            dtAssinaturaContratada.Columns.Add("cpf");
            dtAssinaturaContratada.Columns.Add("data_hora");
            dtAssinaturaContratada.Columns.Add("cargo");
            dtAssinaturaContratada.Columns.Add("ip");


            //_rdo
            assinatura_rdo assinaturaContratada = context.assinatura_rdo.FirstOrDefault(x => x.ass_id_rdo == _rdo.lau_id_laudo && x.obra_colaborador.grupo.gru_nm_nome.ToLower().Contains("contratada")) ?? new assinatura_rdo();
            if (assinaturaContratada.ass_id_obra_colaborador_assinante > 0)
            {
                dtAssinaturaContratada.Rows.Add(assinaturaContratada.obra_colaborador.colaborador.col_nm_colaborador, assinaturaContratada.obra_colaborador.colaborador.col_nr_cpf, assinaturaContratada.ass_dt_assinatura, assinaturaContratada.obra_colaborador.cargo.car_ds_cargo, assinaturaContratada.ass_ds_ip);
            }
            else
            {
                dtAssinaturaContratada.Rows.Add("Não assinado", "Não assinado", "Não assinado", "Não assinado");
            }

            foreach (var item in listaAcidentes)
            {
                dtAcidentes.Rows.Add(item.aci_ds_acidente, item.aci_st_afastamento == "s" ? "Sim" : (item.aci_st_afastamento == "n" ? "Não" : "Não Informado"));
            }

            var dtImagem = new DataTable();
            dtImagem.Columns.Add("imagem", typeof(byte[]));
            dtImagem.Columns.Add("idImagem");
            dtImagem.Columns.Add("imagem1", typeof(byte[]));
            dtImagem.Columns.Add("idImagem1");
            dtImagem.Columns.Add("imagem2", typeof(byte[]));
            dtImagem.Columns.Add("idImagem2");
            dtImagem.Columns.Add("imagem3", typeof(byte[]));
            dtImagem.Columns.Add("idImagem3");



            rdo_imagem linha = new rdo_imagem();

            var rdo_imagem = context.imagem.Where(x => x.ima_id_tarefa == _rdo.lau_id_laudo).ToList();

            if (rdo_imagem.Count > 0)
                gerarRelatorioFotografico = true;

            for (int i = 0; i < rdo_imagem.Count(); i += 4)
            {
                List<imagem> imagens = rdo_imagem.Skip(i).Take(4).ToList();

                if (imagens.Count < 4)
                {
                    int imagensFaltantes = 4 - imagens.Count;
                    for (int j = 0; j < imagensFaltantes; j++)
                    {
                        imagens.Add(new imagem());
                    }
                }

                dtImagem.Rows.Add(
                   convertToBytes(HostingEnvironment.ApplicationPhysicalPath + imagens[0].ima_ds_caminho),
                   imagens[0].ima_id_imagem,
                   convertToBytes(HostingEnvironment.ApplicationPhysicalPath + imagens[1].ima_ds_caminho),
                   imagens[1].ima_id_imagem,
                   convertToBytes(HostingEnvironment.ApplicationPhysicalPath + imagens[2].ima_ds_caminho),
                   imagens[2].ima_id_imagem,
                   convertToBytes(HostingEnvironment.ApplicationPhysicalPath + imagens[3].ima_ds_caminho),
                   imagens[3].ima_id_imagem);
            }

            dtImagem.AcceptChanges();

            return GenerateReport(dtCargosAgrupados, dtEquipamentosAgrupados, _rdo, dtTarefas, dtClima, dtAcidentes, dtAssinaturaContratante, dtAssinaturaContratada, dtImagem, dtItensLaudo, gerarRelatorioFotografico);
        }
        public static byte[] GenerateReport(DataTable dtCargosAgrupados, DataTable dtEquipamentosAgrupados, laudo rdo, DataTable tarefas, DataTable dtClima, DataTable dtAcidentes, DataTable dtAssinaturaContratante, DataTable dtAssinaturaContratada, DataTable dtImagem, DataTable dtItensLaudo, bool gerarRelatorioFotografico)
        {
            rdoappEntities context = new rdoappEntities();
            obra obraLaudo = context.obra.FirstOrDefault(x => x.obr_id_obra == rdo.lau_id_obra);
            colaborador colaboradorLaudo = context.colaborador.FirstOrDefault(x => x.col_id_colaborador == rdo.lau_id_colaborador);
            status_rdo statusRdoLaudo = context.status_rdo.FirstOrDefault(x => x.str_id_status == rdo.lau_id_status);

            DataTable dtDadosRdo = new DataTable();

            string mappath = System.Web.HttpContext.Current.Server.MapPath("~/Api/Contents/Reports/Teste.rdlc");
            LocalReport ReportViewer = new LocalReport();
            ReportViewer.ReportPath = mappath;
            ReportViewer.EnableExternalImages = true;
            string enderecoObra = obraLaudo.obr_ds_logradouro;
            string municipioObra = obraLaudo.municipio.mun_ds_municipio;
            bool licencaLiberaLogo = obraLaudo.empresa.licenca.lic_st_permite_logo_rdo;
            string logoContratada = obraLaudo.obr_ds_foto;

            if (!String.IsNullOrEmpty(obraLaudo.obr_ds_numero))
            {
                enderecoObra = enderecoObra + ", " + obraLaudo.obr_ds_numero;
            }

            if (!String.IsNullOrEmpty(obraLaudo.obr_ds_complemento))
            {
                enderecoObra = enderecoObra + ", " + obraLaudo.obr_ds_complemento;
            }

            if (!String.IsNullOrEmpty(obraLaudo.obr_ds_bairro))
            {
                enderecoObra = enderecoObra + ", " + obraLaudo.obr_ds_bairro;
            }

            enderecoObra = enderecoObra + ", " + municipioObra + " - " + obraLaudo.municipio.uf.ufe_ds_sigla;

            if (!String.IsNullOrEmpty(obraLaudo.obr_ds_cep))
            {
                enderecoObra = enderecoObra + ", CEP: " + Convert.ToUInt64(obraLaudo.obr_ds_cep).ToString(@"00000-000");
            }

            enderecoObra = enderecoObra + ".";


            int diasRestantes = (Convert.ToDateTime(obraLaudo.obr_dt_previsao_fim).Date - (rdo.lau_dt_laudo).Date).Days;

            if (diasRestantes < 0)
            {
                diasRestantes = 0;
            }

            string diaDaSemana = cultureInfo.DateTimeFormat.GetDayName(rdo.lau_dt_laudo.DayOfWeek);

            ReportViewer.DataSources.Add(new ReportDataSource("dtCargosAgrupados", dtCargosAgrupados));
            ReportViewer.DataSources.Add(new ReportDataSource("dtEquipamentosAgrupados", dtEquipamentosAgrupados));
            ReportViewer.DataSources.Add(new ReportDataSource("tarefas", tarefas));
            ReportViewer.DataSources.Add(new ReportDataSource("dtCargosAgrupados", dtCargosAgrupados));
            ReportViewer.DataSources.Add(new ReportDataSource("dtClima", dtClima));
            ReportViewer.DataSources.Add(new ReportDataSource("dtDadosRdo", dtDadosRdo));
            ReportViewer.DataSources.Add(new ReportDataSource("dtAcidentes", dtAcidentes));
            ReportViewer.DataSources.Add(new ReportDataSource("dtAssinaturaContratante", dtAssinaturaContratante));
            ReportViewer.DataSources.Add(new ReportDataSource("dtAssinaturaContratada", dtAssinaturaContratada));
            ReportViewer.DataSources.Add(new ReportDataSource("dtItensLaudo", dtItensLaudo));
            ReportViewer.DataSources.Add(new ReportDataSource("dtImagem", dtImagem));

            ReportViewer.SetParameters(new ReportParameter("NomeObra", obraLaudo.obr_ds_obra));
            ReportViewer.SetParameters(new ReportParameter("StatusRdo", statusRdoLaudo.str_ds_status));
            ReportViewer.SetParameters(new ReportParameter("DataRdo", rdo.lau_dt_laudo.ToString("dd/MM/yyyy")));
            ReportViewer.SetParameters(new ReportParameter("DataRdoDiaSemana", $"{diaDaSemana.ToUpper()}"));
            ReportViewer.SetParameters(new ReportParameter("DataInicioObra", obraLaudo.obr_dt_inicio.ToString("dd/MM/yyyy")));
            ReportViewer.SetParameters(new ReportParameter("DiasDecorridosObra", (rdo.lau_dt_laudo.AddDays(1) - obraLaudo.obr_dt_inicio.Date).Days.ToString()));
            ReportViewer.SetParameters(new ReportParameter("ComentarioRdo", colaboradorLaudo.obra_colaborador.FirstOrDefault(oc => oc.oco_id_obra == rdo.lau_id_obra).oco_st_contratante_contratada == "d" ? rdo.lau_ds_comentario_geracao : rdo.lau_ds_comentario_assinatura)); //Obter comentário contratada
            ReportViewer.SetParameters(new ReportParameter("ComentarioAssinaturaRdo", colaboradorLaudo.obra_colaborador.FirstOrDefault(oc => oc.oco_id_obra == rdo.lau_id_obra).oco_st_contratante_contratada == "t" ? rdo.lau_ds_comentario_geracao : rdo.lau_ds_comentario_assinatura)); //Obter comentario contratante
            ReportViewer.SetParameters(new ReportParameter("EnderecoObra", enderecoObra));
            ReportViewer.SetParameters(new ReportParameter("MunicipioObra", municipioObra + " - " + obraLaudo.municipio.uf.ufe_ds_sigla));
            ReportViewer.SetParameters(new ReportParameter("PrevisaoFinalObra", Convert.ToDateTime(obraLaudo.obr_dt_previsao_fim).ToString("dd/MM/yyyy")));
            ReportViewer.SetParameters(new ReportParameter("DiasRestantes", diasRestantes.ToString()));
            ReportViewer.SetParameters(new ReportParameter("HabilitarRelatorioFotografico", Convert.ToString(gerarRelatorioFotografico)));
            ReportViewer.SetParameters(new ReportParameter("AssinaturaContratante", dtAssinaturaContratante.Rows[0].ItemArray[0].ToString().Equals("Não assinado") ? "" : "Assinado"));
            ReportViewer.SetParameters(new ReportParameter("AssinaturaContratada", dtAssinaturaContratada.Rows[0].ItemArray[0].ToString().Equals("Não assinado") ? "" : "Assinado"));

            string basePath = System.Configuration.ConfigurationManager.AppSettings["basePath"];
            basePath = basePath.Remove(basePath.Length - 1);

            if (!licencaLiberaLogo || string.IsNullOrEmpty(logoContratada))
            {
                logoContratada = "/Assets/images/logo.jpg";
                ReportViewer.SetParameters(new ReportParameter("logoContratada", new Uri(HttpContext.Current.Server.MapPath(basePath + logoContratada)).AbsoluteUri)); //adiciona logomarca 
            }
            else
            {
                ReportViewer.SetParameters(new ReportParameter("logoContratada", new Uri(HttpContext.Current.Server.MapPath(basePath + logoContratada)).AbsoluteUri)); //adiciona logomarca 
            }

            byte[] bytes = ReportViewer.Render("Pdf");

            return bytes;
        }

        private static colaborador obterColaborador(rdoappEntities context, int idColaborador)
        {
            colaborador _colaborador = context.colaborador.FirstOrDefault(x => x.col_id_colaborador == idColaborador);
            if (_colaborador == null)
            {
                throw new Exception("Colaborador não encontrado.");
            }
            return _colaborador;
        }

        private static obra obterObra(rdoappEntities context, int idObra)
        {
            obra _obra = context.obra.FirstOrDefault(x => x.obr_id_obra == idObra);
            if (_obra == null)
            {
                throw new Exception("Obra não encontrada.");
            }
            return _obra;
        }

        public static byte[] convertToBytes(string path)
        {
            if (File.Exists(path))
            {
                var fs = new FileStream(path, FileMode.Open);

                if (fs != null)
                {
                    var br = new BinaryReader(fs);
                    byte[] imgbyteFotoFamilia = new byte[fs.Length + 1];
                    imgbyteFotoFamilia = br.ReadBytes((int)fs.Length);
                    br.Close();
                    fs.Close();

                    return imgbyteFotoFamilia;
                }
            }
            return new Byte[] { };
        }

        public static equipamento ObterEquipamento(int idObraEquipamento)
        {
            rdoappEntities context = new rdoappEntities();
            return context.obra_equipamento.FirstOrDefault(x => x.oeq_id_obra_equipamento == idObraEquipamento).equipamento;
        }
        public static obra_colaborador ObterObraColaborador(int idObraColaborador)
        {
            rdoappEntities context = new rdoappEntities();
            return context.obra_colaborador.FirstOrDefault(x => x.oco_id_obra_colaborador == idObraColaborador);
        }
        public static bool removerRegistrosHistoricoTarefa(rdo rdo)
        {
            List<rdo_tarefa> list = rdo.rdo_tarefa.ToList();
            rdoappEntities context = new rdoappEntities();

            return context.SaveChanges() > 0;
        }
        public static bool SalvarHistoricoTarefa(rdoappEntities context, dynamic param, rdo rdo)
        {
            bool result = true;
            List<tarefa> tarefas = context.tarefa.Where(ta => ta.etapa.eta_id_obra == rdo.rdo_id_obra).ToList();
            List<rdo_tarefa> rdoTarefas = context.rdo_tarefa.Where(rt => rt.rta_id_rdo == rdo.rdo_id_rdo).ToList();
            rdo_tarefa htr = new rdo_tarefa();

            foreach (var item in param.listaTarefas)
            {
                int idTarefa = item.id;
                Guid agrupador = tarefas.FirstOrDefault(ta => ta.tar_id_tarefa == idTarefa).tar_nr_agrupador;
                List<tarefa> tarefasHistoricosNesteDia = tarefas.Where(ta => ta.tar_id_status != 1 && ta.tar_nr_agrupador == agrupador && ta.tar_dt_medicao == rdo.rdo_dt_rdo).ToList();
                if (tarefasHistoricosNesteDia.Count == 0)
                {
                    if (tarefas.FirstOrDefault(ta => ta.tar_nr_agrupador == agrupador && ta.tar_dt_medicao == rdo.rdo_dt_rdo.AddDays(-1)) != null)
                    {
                        tarefasHistoricosNesteDia = tarefas.Where(ta => ta.tar_id_status != 1 && ta.tar_nr_agrupador == agrupador && ta.tar_dt_medicao == rdo.rdo_dt_rdo.AddDays(-1)).ToList();
                        foreach (tarefa tar in tarefasHistoricosNesteDia)
                        {
                            idTarefa = TarefaModel.SalvarNovoHistorico(tar);
                            if (rdoTarefas.Where(rt => rt.rta_id_tarefa == idTarefa).Count() == 0)
                            {
                                htr.rta_id_rdo = rdo.rdo_id_rdo;
                                htr.rta_id_tarefa = idTarefa;

                                context.rdo_tarefa.Add(htr);

                                context.SaveChanges();
                            }
                            else
                            {
                                rdoTarefas.Remove(rdoTarefas.FirstOrDefault(rt => rt.rta_id_tarefa == idTarefa));
                            }
                        }
                    }
                }
                else
                {
                    foreach (tarefa tar in tarefasHistoricosNesteDia)
                    {
                        if (rdoTarefas.Where(rt => rt.rta_id_tarefa == idTarefa).Count() == 0)
                        {
                            htr.rta_id_rdo = rdo.rdo_id_rdo;
                            htr.rta_id_tarefa = tar.tar_id_tarefa;

                            context.rdo_tarefa.Add(htr);

                            context.SaveChanges();
                        }
                        else
                        {
                            rdoTarefas.Remove(rdoTarefas.FirstOrDefault(rt => rt.rta_id_tarefa == idTarefa));
                        }
                    }
                }
            }
            foreach (rdo_tarefa item in rdoTarefas)
            {
                context.rdo_tarefa.Remove(item);
                context.SaveChanges();
            }
            return result;
        }


        public static bool SalvarHistoricoColaboradores(rdo_tarefa htr, rdoappEntities context, int idTarefa)
        {
            bool result = true;
            tarefa objTarefa = context.tarefa.FirstOrDefault(x => x.tar_id_tarefa == idTarefa);
            List<obra_tarefa_colaborador> listaObraTarefaColaborador = objTarefa.obra_tarefa_colaborador.ToList();

            foreach (obra_tarefa_colaborador otc in listaObraTarefaColaborador)
            {
                result = context.SaveChanges() > 0;
            }


            return result;
        }
        public static bool SalvarHistoricoEquipamentos(rdo_tarefa htr, rdoappEntities context, int idTarefa)
        {
            bool result = true;
            tarefa objTarefa = context.tarefa.FirstOrDefault(x => x.tar_id_tarefa == idTarefa);
            List<obra_tarefa_equipamento> listaObraTarefaEquipamento = objTarefa.obra_tarefa_equipamento.ToList();
            foreach (obra_tarefa_equipamento ote in listaObraTarefaEquipamento)
            {
                result = context.SaveChanges() > 0;
            }


            return result;
        }
        internal static bool Deletar(dynamic param)
        {
            int idRdo = (int)param.idRdo;
            int idObra = (int)param.idObra;

            RdoViewModel rdo = new RdoViewModel();

            rdoappEntities context = new rdoappEntities();

            try
            {
                context.rdo.Where(x => x.rdo_id_rdo == idRdo).ToList().ForEach(y => context.rdo.Remove(y));

                context.SaveChanges();
            }
            catch (Exception)
            {
                return false;
            }

            return true;
        }
        internal static RdoViewModel ObterRegistro(dynamic param)
        {
            int idRdo = (int)param;

            RdoViewModel rdo = new RdoViewModel();
            rdoappEntities context = new rdoappEntities();
            rdo resultado = context.rdo.FirstOrDefault(rdoIns => rdoIns.rdo_id_rdo == idRdo);

            rdo.IdRdo = resultado.rdo_id_rdo;
            rdo.DataRdo = resultado.rdo_dt_rdo == null || resultado.rdo_dt_rdo == DateTime.MinValue ? "" : resultado.rdo_dt_rdo.Date.ToString().Substring(0, 10);
            rdo.Comentario = resultado.rdo_ds_comentario_geracao;
            rdo.StatusRdo = resultado.rdo_id_status;
            rdo.ClimaManhaCheckValue = resultado.rdo_ds_clima_manha;
            rdo.ClimaTardeCheckValue = resultado.rdo_ds_clima_tarde;
            rdo.ClimaNoiteCheckValue = resultado.rdo_ds_clima_noite;
            rdo.ChuvaManhaCheckValue = resultado.rdo_ds_chuva_manha;
            rdo.ChuvaTardeCheckValue = resultado.rdo_ds_chuva_tarde;
            rdo.ChuvaNoiteCheckValue = resultado.rdo_ds_chuva_noite;
            rdo.tipoComentarioAssinatura = resultado.rdo_tp_comentario_assinatura;
            rdo.tipoComentarioGeracao = resultado.rdo_tp_comentario_geracao == null ? "0" : resultado.rdo_tp_comentario_geracao == "P" ? "1" : "2";
            rdo.improdutividadeCondicoesClimaticas = resultado.improdutividade.imp_st_clima;
            rdo.improdutividadeMateriais = resultado.improdutividade.imp_st_material;
            rdo.improdutividadeParalizacoes = resultado.improdutividade.imp_st_paralizacao;
            rdo.improdutividadeEquipamentos = resultado.improdutividade.imp_st_equipamento;
            rdo.improdutividadeContratante = resultado.improdutividade.imp_st_contratante;
            rdo.improdutividadeFornecedores = resultado.improdutividade.imp_st_fornecedores;
            rdo.improdutividadeProjeto = resultado.improdutividade.imp_st_projeto;
            rdo.improdutividadePlanejamento = resultado.improdutividade.imp_st_planejamento;
            rdo.improdutividadeAcidente = resultado.improdutividade.imp_st_acidentes;
            rdo.improdutividadeMaodeObra = resultado.improdutividade.imp_st_maodeobra;
            rdo.statusContratanteContratadaDonoRdo = resultado.colaborador.obra_colaborador.FirstOrDefault(oc => oc.oco_id_obra == resultado.rdo_id_obra).oco_st_contratante_contratada;

            rdo.listaTarefas = new List<TarefaViewModel>();

            rdo.listaImagens = ImagemModel.ObterImagensRdo(idRdo);
            rdo.listaTarefas = TarefaModel.ListaTarefaRdo(idRdo);


            return rdo;
        }
        internal static bool Assinar(dynamic param)
        {
            rdoappEntities context = new rdoappEntities();
            int idRdo = (int)param.rdo.idRdo;
            int idAssinante = (int)param.rdo.idAssinante;
            string ip = param.objIp.ip;
            rdo _rdo = context.rdo.Where(x => x.rdo_id_rdo == idRdo).FirstOrDefault() ?? new rdo();


            obra_colaborador _obra_colaborador = context.obra_colaborador.Where(x => x.oco_id_obra_colaborador == idAssinante).FirstOrDefault() ?? new obra_colaborador();
            string tipoAssinante = _obra_colaborador.oco_st_contratante_contratada;
            tipoAssinante = _obra_colaborador.grupo.gru_nm_nome.ToLower().Contains("contratante") ? "t" : (_obra_colaborador.grupo.gru_nm_nome.ToLower().Contains("contratada") ? "d" : "");


            if (_rdo.status_rdo != null && (_rdo.status_rdo.str_ds_status.ToLower().Contains("contratada") && tipoAssinante == "d"))
            {
                throw new Exception("Esse RDO já foi assinado pela contratada.");
            }
            if (_rdo.status_rdo != null && (_rdo.status_rdo.str_ds_status.ToLower().Contains("contratante") && tipoAssinante == "d"))
            {
                throw new Exception("Esse RDO já foi assinado pela contratada.");
            }
            if (_rdo.status_rdo != null && (_rdo.status_rdo.str_ds_status.ToLower().Contains("contratante") && tipoAssinante == "t"))
            {
                throw new Exception("Esse RDO já foi assinado pela contratante.");
            }


            if (tipoAssinante == "t")
            {
                _rdo.rdo_id_status = 2;
            }
            else if (tipoAssinante == "d")
            {
                _rdo.rdo_id_status = 3;
            }

            if (!String.IsNullOrEmpty(Convert.ToString(param.rdo.comentarioAssinatura)))
            {
                _rdo.rdo_ds_comentario_assinatura = param.rdo.comentarioAssinatura;
                _rdo.rdo_tp_comentario_assinatura = param.rdo.tipoComentarioAssinatura == 0 || String.IsNullOrEmpty(Convert.ToString(param.rdo.comentarioAssinatura)) ? null : param.rdo.tipoComentarioAssinatura == 1 ? "P" : "N";
            }

            if (_rdo.rdo_id_rdo > 0)
            {
                context.rdo.Attach(_rdo);
                context.Entry(_rdo).State = System.Data.Entity.EntityState.Modified;
            }

            bool result = context.SaveChanges() > 0;


            assinatura_rdo _assinatura_rdo = context.assinatura_rdo.Where(x => x.ass_id_obra_colaborador_assinante == idAssinante && x.ass_id_rdo == idRdo).FirstOrDefault() ?? new assinatura_rdo();
            _assinatura_rdo.ass_id_obra_colaborador_assinante = idAssinante;
            _assinatura_rdo.ass_id_rdo = idRdo;
            _assinatura_rdo.ass_dt_assinatura = DateTime.Now;
            _assinatura_rdo.ass_ds_ip = ip;



            if (_assinatura_rdo.ass_id_assinatura > 0)
            {
                context.assinatura_rdo.Attach(_assinatura_rdo);
                context.Entry(_assinatura_rdo).State = System.Data.Entity.EntityState.Modified;
            }
            else
            {
                context.assinatura_rdo.Add(_assinatura_rdo);
            }

            if (result)
            {
                result = context.SaveChanges() > 0;
            }

            return result;
        }
    }

    public class LaudoViewModel
    {
        public bool? gerarRelatorioFotografico { get; set; }
        public int lau_id_laudo { get; set; }
        public int lau_id_status { get; set; }
        public int lau_id_obra { get; set; }
        public string lau_dt_laudo { get; set; }
        public string lau_ds_comentario_assinatura { get; set; }
        public int lau_id_colaborador { get; set; }
        public System.DateTime lau_dt_geracao { get; set; }
        public string lau_tp_comentario_assinatura { get; set; }
        public string lau_ds_comentario_geracao { get; set; }
        public string lau_tp_comentario_geracao { get; set; }
        public bool lau_tp_nivel_cloro { get; set; }
        public bool lau_tp_ph { get; set; }
        public bool lau_tp_limpidez { get; set; }
        public bool lau_tp_superficie { get; set; }
        public bool lau_tp_fundo { get; set; }
        public bool lau_tp_nivel_cloro_2 { get; set; }
        public bool lau_tp_nivel_bacterias { get; set; }
        public bool lau_tp_nivel_proliferacao { get; set; }
        public string DiaDaSemana { get; set; }
        public string DescricaoStatus { get; set; }
        public virtual colaborador colaborador { get; set; }
        public virtual status_rdo status_rdo { get; set; }
        public virtual obra obra { get; set; }

        public LaudoViewModel()
        {

        }
    }
}