/** Paridade prod `RdoController.habilitarAssinarRdo` — true = botão desabilitado. */
export function rdoAssinarEditarDisabled(
  statusRdo: number,
  contratanteContratadaUsuario: string | undefined,
): boolean {
  const cc = (contratanteContratadaUsuario ?? '').trim().toLowerCase()

  if (cc === 't' && statusRdo === 1) return true
  if (cc === 't' && statusRdo === 3) return false
  if (cc === 'd' && statusRdo === 1) return false
  if (cc === 'd' && statusRdo === 3) return true
  if (statusRdo === 2) return true
  return true
}
