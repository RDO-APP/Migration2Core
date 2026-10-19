/**
 * Contrato M1 — Equipamentos (EQ-R + EQ-M)
 * Fonte: EquipamentosMobile @ feature/alteracoes_apontador (14cf5d3)
 * Não importar secrets; senha em LoginResponse existe no mobile legado — EQ-R homolog preferir cookie/BFF.
 */

export type ApiEnv = 'prod' | 'homolog';

export const API_BASE = {
  prod: 'https://sistema.rdoapp.com.br',
  homologLegacyLan: 'http://192.168.0.8:58951', // appVariant — não usar web
  homologWeb: 'https://homolog.sistema.rdoapp.com.br',
} as const;

// --- Auth (LoginUser) ---

export interface LoginCredentials {
  cpf: string;
  senha: string;
  email?: string;
  manterLogado?: boolean;
}

export interface RoutePermission {
  name: string;
  path: string;
  permissions: string[];
}

export interface LoginUsuario {
  id: number;
  nomeUsuario: string;
  email: string;
  idGrupo: number;
}

export interface LoginResponse {
  usuario: LoginUsuario;
  routes: RoutePermission[];
  menu?: unknown;
}

// --- Obra ---

export interface ObterObrasInput {
  idColaborador: number;
  dataFim?: string;
  dataInicio?: string;
  dataPrevisaoFim?: string;
  descricao?: string;
  idContratada?: number;
  idContratante?: number;
  idMunicipio?: number;
  idUf?: number;
  setor?: number;
  statusObra?: number;
}

export interface ObraListItem {
  idColaborador: number;
  idObra: number;
  descricao: string;
  cidadeEstado?: string;
  contratanteContratada?: string;
  statusBasicaGratuita?: string;
  progressoPorcentagem?: number;
  classeStatusCss?: string;
  obraFinalizada?: boolean;
}

export interface LoginObraPayload {
  idObra: number;
  idUsuario: number;
  obra: unknown;
  user: unknown;
}

// --- Cards (etapa/Get) ---

export interface StatusPermitido {
  id: number;
  nome: string;
  cssClass: string;
}

export interface TarefaCard {
  id: number;
  descricao: string;
  status: number;
  nomeStatus: string;
  idEtapa: number;
  dataInicio?: string;
  dataPrevisaoFim?: string;
  percentualConcluido?: number;
  percentualExtrapolado?: string;
  classeStatusCss?: string;
  marcado?: boolean;
  rdoAssinado?: boolean;
  listaStatusPermitidos?: StatusPermitido[];
}

export interface EtapaComTarefas {
  id: number;
  titulo: string;
  ordem: number;
  idObra: number;
  tituloObra?: string;
  tarefas: TarefaCard[];
}

// --- HTTP helpers (assinatura mobile) ---

export type HttpMethod = 'GET' | 'POST';

export interface ApiCallOptions {
  method: HttpMethod;
  headers?: Record<string, string>;
  body?: unknown;
  credentials?: RequestCredentials;
}
