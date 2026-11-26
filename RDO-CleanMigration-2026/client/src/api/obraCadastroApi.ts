export type ObraCadastroLookup = { id: number; nome: string }

export type ObraCadastro = {
  id: number
  nova?: boolean
  descricao: string
  dataInicio: string
  dataPrevisaoFim: string
  logradouro: string
  numero: string
  complemento?: string
  bairro: string
  cep: string
  idUf?: number
  idMunicipio?: number
  idContratante?: number
  idContratada?: number
  areaTotal?: number | null
  areaConstruida?: number | null
  cidadeEstado: string
  finalizada: boolean
  descricaoFoto?: string
  empresas?: ObraCadastroLookup[]
  idsEmpresasDoUsuario?: number[]
  /** Copiar obra: origem das listas colab/equip. */
  idObraOrigemCopia?: number
}

export type ObraCadastroSaveResult = {
  ok: boolean
  errorMessage?: string | null
  obraNome?: string | null
  obraId?: number | null
}

export type ViaCepResult = {
  cep?: string
  logradouro?: string
  bairro?: string
  localidade?: string
  uf?: string
  erro?: boolean
}

async function readJson<T>(res: Response, fallback: string): Promise<T> {
  if (res.status === 401) {
    throw new Error('Sessão expirada ou obra não selecionada. Volte a Escolher obra.')
  }
  if (!res.ok) {
    const text = await res.text()
    let fromJson: string | undefined
    try {
      const j = JSON.parse(text) as {
        message?: string
        errorMessage?: string
        title?: string
        detail?: string
        errors?: Record<string, string[]>
      }
      const firstErr = j.errors ? Object.values(j.errors).flat()[0] : undefined
      fromJson = j.errorMessage || j.message || j.detail || firstErr || j.title
    } catch {
      /* */
    }
    throw new Error(fromJson?.trim() || text.slice(0, 400) || `Erro ${res.status} (${fallback}).`)
  }
  return res.json() as Promise<T>
}

export async function fetchObraCadastro(
  opts: boolean | { nova?: boolean; copiar?: number } = false,
): Promise<ObraCadastro> {
  const q = new URLSearchParams()
  if (typeof opts === 'boolean') {
    if (opts) q.set('nova', 'true')
  } else {
    if (opts.copiar && opts.copiar > 0) q.set('copiar', String(opts.copiar))
    else if (opts.nova) q.set('nova', 'true')
  }
  const qs = q.toString()
  const res = await fetch(`/api/bff/obras/cadastro${qs ? `?${qs}` : ''}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'cadastro obra')
}

/** Copiar obra: pré-visualização (somente leitura) do time/frota da origem; clonados ao Salvar. */
export async function fetchCopiaVinculos(idObraOrigem: number): Promise<{
  colaboradores: import('./colaboradorApi').ColaboradorIndexItem[]
  equipamentos: import('./equipamentoApi').EquipamentoIndexItem[]
}> {
  const res = await fetch(`/api/bff/obras/cadastro/copia-vinculos?copiar=${idObraOrigem}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'vínculos da obra origem')
}

export async function saveObraCadastro(body: {
  nova?: boolean
  /** Copiar obra — clona obra_colaborador + obra_equipamento no Create. */
  idObraOrigemCopia?: number
  descricao: string
  dataInicio: string
  dataPrevisaoFim: string
  logradouro: string
  numero: string
  complemento?: string
  bairro: string
  cep: string
  idMunicipio: number
  idContratante: number
  idContratada: number
  areaTotal?: number | null
  areaConstruida?: number | null
  foto?: string | null
  removerFoto?: boolean
}): Promise<ObraCadastroSaveResult> {
  const { nova, ...fields } = body
  const q = nova ? '?nova=true' : ''
  const res = await fetch(`/api/bff/obras/cadastro${q}`, {
    method: 'PUT',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(fields),
  })
  return readJson(res, 'salvar obra')
}

/** Busca CEP via BFF (proxy ViaCEP same-origin). */
export async function fetchViaCep(cepDigits: string): Promise<ViaCepResult | null> {
  const cep = cepDigits.replace(/\D/g, '')
  if (cep.length !== 8) return null
  const res = await fetch(`/api/bff/obras/cep/${cep}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  if (!res.ok) return null
  const data = (await res.json()) as ViaCepResult
  if (data.erro) return null
  return data
}
