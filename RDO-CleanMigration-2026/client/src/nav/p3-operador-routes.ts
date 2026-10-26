/**
 * Mapa canônico P3 — prod Angular (`#/…`) → rotas MVC homolog.
 * Uso: navegação meio-termo (EmMigracao) até M5/M7. Manual: docs/migracao/p3-botoes-habilitacao-m7.md
 */
export type P3NavCardActions = {
  alterarStatus: string
  visualizar: string
  historicoMedicao: string
  editar: string
  relatorioHorasEquipamento: string
  novaMedicao: string
  excluir: string
}

export const P3_NAV = {
  /** 1) Header — OperadorShell */
  header: {
    logoEscolher: '/Obra/Escolher',
    trocarSenha: '/Account/ChangePassword',
    dashboardObra: '/Dashboard/Index',
    rdoListagem: '/Rdo/Index',
    tarefaCards: '/Tarefa/Cards',
    chartGeral: '/Chart/Index',
    novaObraCadastro: '/Obra/Cadastro',
  },
  /** 2) Toolbar — CardsToolbar + selecionar tudo */
  toolbar: {
    gerarRdo: '/Rdo/Cadastro',
    editarObra: '/Obra/Cadastro',
    efetivoDiario: '/Efetivo/Index',
    listaTarefas: '/Tarefa/Index',
    adicionarTarefa: '/Tarefa/Cadastro',
    adicionarEtapa: '/Etapa/Cadastro',
    /** Abre painel filtro na própria P3 (query). */
    filtroQuery: '/Tarefa/Cards?filtro=1',
    alterarStatusEmMassa: '/Tarefa/AlterarStatusEmMassa',
  },
  /** 3) Card — TaskCardAgrupador (+ placeholder por etapa) */
  card(tarefaId: number, etapaId?: number): P3NavCardActions & { adicionarNovaTarefa: string } {
    const q = (extra: Record<string, string | number | boolean>) => {
      const params = new URLSearchParams()
      params.set('id', String(tarefaId))
      for (const [k, v] of Object.entries(extra)) {
        params.set(k, String(v))
      }
      return `/Tarefa/Cadastro?${params.toString()}`
    }
    return {
      alterarStatus: `/Tarefa/AlterarStatus?id=${tarefaId}`,
      visualizar: q({ modo: 'visualizar' }),
      historicoMedicao: `/Tarefa/HistoricoMedicao?id=${tarefaId}`,
      editar: `/Tarefa/Cadastro?id=${tarefaId}`,
      relatorioHorasEquipamento: `/Tarefa/RelatorioHorasEquipamento?id=${tarefaId}`,
      novaMedicao: q({ novaMedicao: 1 }),
      excluir: `/Tarefa/Excluir?id=${tarefaId}`,
      adicionarNovaTarefa:
        etapaId != null ? `/Tarefa/Cadastro?etapaId=${etapaId}` : P3_NAV.toolbar.adicionarTarefa,
    }
  },
} as const

/** Navegação full-page (evita SPA tratar rota como Cards). */
export function goOperador(url: string): void {
  window.location.assign(url)
}
