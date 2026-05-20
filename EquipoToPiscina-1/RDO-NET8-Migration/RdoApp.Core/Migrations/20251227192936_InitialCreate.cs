using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RdoApp.Core.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "cargo",
                columns: table => new
                {
                    car_id_cargo = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    car_ds_cargo = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_cargo", x => x.car_id_cargo);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "colaborador",
                columns: table => new
                {
                    col_id_colaborador = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    col_nm_colaborador = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    col_nr_cpf = table.Column<string>(type: "varchar(14)", maxLength: 14, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    col_dt_nascimento = table.Column<DateTime>(type: "datetime(6)", nullable: true),
                    col_dt_insercao = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    col_dt_ultima_atualizacao = table.Column<DateTime>(type: "datetime(6)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_colaborador", x => x.col_id_colaborador);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "grupo",
                columns: table => new
                {
                    gru_id_grupo = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    gru_nm_nome = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    gru_id_menu = table.Column<int>(type: "int", nullable: false),
                    gru_id_licenca = table.Column<int>(type: "int", nullable: true),
                    gru_st_diretor = table.Column<int>(type: "int", nullable: true),
                    gru_st_contratante = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_grupo", x => x.gru_id_grupo);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "obra",
                columns: table => new
                {
                    obr_id_obra = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    obr_ds_obra = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    obr_dt_inicio = table.Column<DateTime>(type: "datetime(6)", nullable: true),
                    obr_dt_previsao_fim = table.Column<DateTime>(type: "datetime(6)", nullable: true),
                    obr_dt_insercao = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    obr_dt_ultima_atualizacao = table.Column<DateTime>(type: "datetime(6)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_obra", x => x.obr_id_obra);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "status_tarefa",
                columns: table => new
                {
                    sta_id_status = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    sta_ds_status = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    sta_dt_insercao = table.Column<DateTime>(type: "datetime(6)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_status_tarefa", x => x.sta_id_status);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "tipo_equipamento",
                columns: table => new
                {
                    teq_id_tipo_equipamento = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    teq_ds_tipo_equipamento = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tipo_equipamento", x => x.teq_id_tipo_equipamento);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "etapa",
                columns: table => new
                {
                    eta_id_etapa = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    eta_ds_etapa = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    eta_id_obra = table.Column<int>(type: "int", nullable: false),
                    eta_dt_insercao = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    eta_dt_ultima_atualizacao = table.Column<DateTime>(type: "datetime(6)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_etapa", x => x.eta_id_etapa);
                    table.ForeignKey(
                        name: "FK_etapa_obra_eta_id_obra",
                        column: x => x.eta_id_obra,
                        principalTable: "obra",
                        principalColumn: "obr_id_obra",
                        onDelete: ReferentialAction.Restrict);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "laudo",
                columns: table => new
                {
                    lau_id_laudo = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    lau_dt_laudo = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    lau_id_obra = table.Column<int>(type: "int", nullable: false),
                    lau_id_colaborador = table.Column<int>(type: "int", nullable: false),
                    lau_dt_geracao = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    lau_id_status = table.Column<int>(type: "int", nullable: false),
                    lau_tp_nivel_cloro = table.Column<int>(type: "int", nullable: true),
                    lau_tp_ph = table.Column<int>(type: "int", nullable: true),
                    lau_tp_alcalinidade = table.Column<int>(type: "int", nullable: true),
                    lau_tp_limpidez = table.Column<bool>(type: "tinyint(1)", nullable: true),
                    lau_tp_superficie = table.Column<bool>(type: "tinyint(1)", nullable: true),
                    lau_tp_fundo = table.Column<bool>(type: "tinyint(1)", nullable: true),
                    lau_tp_nivel_bacterias = table.Column<bool>(type: "tinyint(1)", nullable: true),
                    lau_tp_nivel_proliferacao = table.Column<bool>(type: "tinyint(1)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_laudo", x => x.lau_id_laudo);
                    table.ForeignKey(
                        name: "FK_laudo_colaborador_lau_id_colaborador",
                        column: x => x.lau_id_colaborador,
                        principalTable: "colaborador",
                        principalColumn: "col_id_colaborador",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_laudo_obra_lau_id_obra",
                        column: x => x.lau_id_obra,
                        principalTable: "obra",
                        principalColumn: "obr_id_obra",
                        onDelete: ReferentialAction.Restrict);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "obra_colaborador",
                columns: table => new
                {
                    oco_id_obra_colaborador = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    oco_id_obra = table.Column<int>(type: "int", nullable: false),
                    oco_id_colaborador = table.Column<int>(type: "int", nullable: false),
                    oco_id_cargo = table.Column<int>(type: "int", nullable: false),
                    oco_id_grupo = table.Column<int>(type: "int", nullable: false),
                    oco_dt_contratacao = table.Column<DateTime>(type: "datetime(6)", nullable: true),
                    oco_st_contratante_contratada = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_obra_colaborador", x => x.oco_id_obra_colaborador);
                    table.ForeignKey(
                        name: "FK_obra_colaborador_cargo_oco_id_cargo",
                        column: x => x.oco_id_cargo,
                        principalTable: "cargo",
                        principalColumn: "car_id_cargo",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_obra_colaborador_colaborador_oco_id_colaborador",
                        column: x => x.oco_id_colaborador,
                        principalTable: "colaborador",
                        principalColumn: "col_id_colaborador",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_obra_colaborador_grupo_oco_id_grupo",
                        column: x => x.oco_id_grupo,
                        principalTable: "grupo",
                        principalColumn: "gru_id_grupo",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_obra_colaborador_obra_oco_id_obra",
                        column: x => x.oco_id_obra,
                        principalTable: "obra",
                        principalColumn: "obr_id_obra",
                        onDelete: ReferentialAction.Restrict);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "equipamento",
                columns: table => new
                {
                    equ_id_equipamento = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    equ_ds_equipamento = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    equ_ds_marca = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    equ_ds_modelo = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    equ_id_tipo_equipamento = table.Column<int>(type: "int", nullable: false),
                    equ_ds_imagem = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_equipamento", x => x.equ_id_equipamento);
                    table.ForeignKey(
                        name: "FK_equipamento_tipo_equipamento_equ_id_tipo_equipamento",
                        column: x => x.equ_id_tipo_equipamento,
                        principalTable: "tipo_equipamento",
                        principalColumn: "teq_id_tipo_equipamento",
                        onDelete: ReferentialAction.Restrict);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "tarefa",
                columns: table => new
                {
                    tar_id_tarefa = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tar_nr_agrupador = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    tar_id_status = table.Column<int>(type: "int", nullable: false),
                    tar_id_etapa = table.Column<int>(type: "int", nullable: false),
                    tar_id_unidade = table.Column<int>(type: "int", nullable: true),
                    tar_ds_tarefa = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    tar_nr_qtd_construida = table.Column<float>(type: "float", nullable: true),
                    tar_dt_inicio = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    tar_dt_previsao_fim = table.Column<DateTime>(type: "datetime(6)", nullable: true),
                    tar_dt_fim = table.Column<DateTime>(type: "datetime(6)", nullable: true),
                    tar_ds_comentario = table.Column<string>(type: "varchar(1000)", maxLength: 1000, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    tar_ds_foto = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    tar_nr_horas_trabalhadas = table.Column<int>(type: "int", nullable: true),
                    tar_dt_medicao_hora_final = table.Column<TimeSpan>(type: "time(6)", nullable: true),
                    tar_dt_medicao_hora_inicial = table.Column<TimeSpan>(type: "time(6)", nullable: true),
                    tar_dt_medicao = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    tar_vl_valor_unitario = table.Column<decimal>(type: "decimal(65,30)", nullable: true),
                    tar_id_colaborador_insercao = table.Column<int>(type: "int", nullable: false),
                    tar_dt_insercao = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    tar_dt_ultima_atualizacao = table.Column<DateTime>(type: "datetime(6)", nullable: true),
                    tar_nr_qtd_previsao = table.Column<decimal>(type: "decimal(65,30)", nullable: true),
                    tar_dt_medicao_horimetro_total = table.Column<float>(type: "float", nullable: true),
                    tar_codigo_paralizacao = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    tar_dt_medicao_horimetro_inicial = table.Column<float>(type: "float", nullable: true),
                    tar_dt_medicao_horimetro_final = table.Column<float>(type: "float", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tarefa", x => x.tar_id_tarefa);
                    table.ForeignKey(
                        name: "FK_tarefa_colaborador_tar_id_colaborador_insercao",
                        column: x => x.tar_id_colaborador_insercao,
                        principalTable: "colaborador",
                        principalColumn: "col_id_colaborador",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_tarefa_etapa_tar_id_etapa",
                        column: x => x.tar_id_etapa,
                        principalTable: "etapa",
                        principalColumn: "eta_id_etapa",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_tarefa_status_tarefa_tar_id_status",
                        column: x => x.tar_id_status,
                        principalTable: "status_tarefa",
                        principalColumn: "sta_id_status",
                        onDelete: ReferentialAction.Restrict);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "obra_equipamento",
                columns: table => new
                {
                    oeq_id_obra_equipamento = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    oeq_id_obra = table.Column<int>(type: "int", nullable: false),
                    oeq_id_equipamento = table.Column<int>(type: "int", nullable: false),
                    oeq_tp_aquisicao = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    oeq_ds_fabricante_fornecedor = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    oeq_dt_aquisicao = table.Column<DateTime>(type: "datetime(6)", nullable: true),
                    oeq_ds_contato = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    oeq_ds_telefone = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_obra_equipamento", x => x.oeq_id_obra_equipamento);
                    table.ForeignKey(
                        name: "FK_obra_equipamento_equipamento_oeq_id_equipamento",
                        column: x => x.oeq_id_equipamento,
                        principalTable: "equipamento",
                        principalColumn: "equ_id_equipamento",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_obra_equipamento_obra_oeq_id_obra",
                        column: x => x.oeq_id_obra,
                        principalTable: "obra",
                        principalColumn: "obr_id_obra",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "obra_tarefa_colaborador",
                columns: table => new
                {
                    otc_id_obra_tarefa_colaborador = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    otc_id_obra_colaborador = table.Column<int>(type: "int", nullable: false),
                    otc_id_tarefa = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_obra_tarefa_colaborador", x => x.otc_id_obra_tarefa_colaborador);
                    table.ForeignKey(
                        name: "FK_obra_tarefa_colaborador_obra_colaborador_otc_id_obra_colabor~",
                        column: x => x.otc_id_obra_colaborador,
                        principalTable: "obra_colaborador",
                        principalColumn: "oco_id_obra_colaborador",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_obra_tarefa_colaborador_tarefa_otc_id_tarefa",
                        column: x => x.otc_id_tarefa,
                        principalTable: "tarefa",
                        principalColumn: "tar_id_tarefa",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "obra_tarefa_equipamento",
                columns: table => new
                {
                    ote_id_obra_tarefa_euipamento = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    ote_id_obra_equipamento = table.Column<int>(type: "int", nullable: false),
                    ote_id_tarefa = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_obra_tarefa_equipamento", x => x.ote_id_obra_tarefa_euipamento);
                    table.ForeignKey(
                        name: "FK_obra_tarefa_equipamento_obra_equipamento_ote_id_obra_equipam~",
                        column: x => x.ote_id_obra_equipamento,
                        principalTable: "obra_equipamento",
                        principalColumn: "oeq_id_obra_equipamento",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_obra_tarefa_equipamento_tarefa_ote_id_tarefa",
                        column: x => x.ote_id_tarefa,
                        principalTable: "tarefa",
                        principalColumn: "tar_id_tarefa",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "IX_equipamento_equ_id_tipo_equipamento",
                table: "equipamento",
                column: "equ_id_tipo_equipamento");

            migrationBuilder.CreateIndex(
                name: "IX_etapa_eta_id_obra",
                table: "etapa",
                column: "eta_id_obra");

            migrationBuilder.CreateIndex(
                name: "IX_laudo_lau_id_colaborador",
                table: "laudo",
                column: "lau_id_colaborador");

            migrationBuilder.CreateIndex(
                name: "IX_laudo_lau_id_obra",
                table: "laudo",
                column: "lau_id_obra");

            migrationBuilder.CreateIndex(
                name: "IX_obra_colaborador_oco_id_cargo",
                table: "obra_colaborador",
                column: "oco_id_cargo");

            migrationBuilder.CreateIndex(
                name: "IX_obra_colaborador_oco_id_colaborador",
                table: "obra_colaborador",
                column: "oco_id_colaborador");

            migrationBuilder.CreateIndex(
                name: "IX_obra_colaborador_oco_id_grupo",
                table: "obra_colaborador",
                column: "oco_id_grupo");

            migrationBuilder.CreateIndex(
                name: "IX_obra_colaborador_oco_id_obra",
                table: "obra_colaborador",
                column: "oco_id_obra");

            migrationBuilder.CreateIndex(
                name: "IX_obra_equipamento_oeq_id_equipamento",
                table: "obra_equipamento",
                column: "oeq_id_equipamento");

            migrationBuilder.CreateIndex(
                name: "IX_obra_equipamento_oeq_id_obra",
                table: "obra_equipamento",
                column: "oeq_id_obra");

            migrationBuilder.CreateIndex(
                name: "IX_obra_tarefa_colaborador_otc_id_obra_colaborador",
                table: "obra_tarefa_colaborador",
                column: "otc_id_obra_colaborador");

            migrationBuilder.CreateIndex(
                name: "IX_obra_tarefa_colaborador_otc_id_tarefa",
                table: "obra_tarefa_colaborador",
                column: "otc_id_tarefa");

            migrationBuilder.CreateIndex(
                name: "IX_obra_tarefa_equipamento_ote_id_obra_equipamento",
                table: "obra_tarefa_equipamento",
                column: "ote_id_obra_equipamento");

            migrationBuilder.CreateIndex(
                name: "IX_obra_tarefa_equipamento_ote_id_tarefa",
                table: "obra_tarefa_equipamento",
                column: "ote_id_tarefa");

            migrationBuilder.CreateIndex(
                name: "IX_tarefa_tar_id_colaborador_insercao",
                table: "tarefa",
                column: "tar_id_colaborador_insercao");

            migrationBuilder.CreateIndex(
                name: "IX_tarefa_tar_id_etapa",
                table: "tarefa",
                column: "tar_id_etapa");

            migrationBuilder.CreateIndex(
                name: "IX_tarefa_tar_id_status",
                table: "tarefa",
                column: "tar_id_status");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "laudo");

            migrationBuilder.DropTable(
                name: "obra_tarefa_colaborador");

            migrationBuilder.DropTable(
                name: "obra_tarefa_equipamento");

            migrationBuilder.DropTable(
                name: "obra_colaborador");

            migrationBuilder.DropTable(
                name: "obra_equipamento");

            migrationBuilder.DropTable(
                name: "tarefa");

            migrationBuilder.DropTable(
                name: "cargo");

            migrationBuilder.DropTable(
                name: "grupo");

            migrationBuilder.DropTable(
                name: "equipamento");

            migrationBuilder.DropTable(
                name: "colaborador");

            migrationBuilder.DropTable(
                name: "etapa");

            migrationBuilder.DropTable(
                name: "status_tarefa");

            migrationBuilder.DropTable(
                name: "tipo_equipamento");

            migrationBuilder.DropTable(
                name: "obra");
        }
    }
}
