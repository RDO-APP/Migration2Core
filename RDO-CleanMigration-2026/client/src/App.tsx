import { CardsPage } from './pages/CardsPage'
import { TarefaIndexPage } from './pages/TarefaIndexPage'
import { ChartIndexPage } from './pages/ChartIndexPage'
import { DashboardPage } from './pages/DashboardPage'
import { EscolherPage } from './pages/EscolherPage'
import { LoginPage } from './pages/LoginPage'
import { RdoCadastroPage } from './pages/RdoCadastroPage'
import { RdoIndexPage } from './pages/RdoIndexPage'
import { TarefaCadastroPage } from './pages/TarefaCadastroPage'
import { EtapaCadastroPage } from './pages/EtapaCadastroPage'
import { EtapaIndexPage } from './pages/EtapaIndexPage'
import { EfetivoIndexPage } from './pages/EfetivoIndexPage'
import { ObraCadastroPage } from './pages/ObraCadastroPage'
import { ObraIndexPage } from './pages/ObraIndexPage'
import { EmpresaIndexPage } from './pages/EmpresaIndexPage'
import { ColaboradorIndexPage } from './pages/ColaboradorIndexPage'
import { EquipamentoIndexPage } from './pages/EquipamentoIndexPage'
import { detectOperadorPage } from './route'

function App() {
  const page = detectOperadorPage()
  if (page === 'login') {
    return <LoginPage />
  }
  if (page === 'escolher') {
    return <EscolherPage />
  }
  if (page === 'tarefa-index') {
    return <TarefaIndexPage />
  }
  if (page === 'tarefa-cadastro') {
    return <TarefaCadastroPage />
  }
  if (page === 'etapa-cadastro') {
    return <EtapaCadastroPage />
  }
  if (page === 'etapa-index') {
    return <EtapaIndexPage />
  }
  if (page === 'rdo-cadastro') {
    return <RdoCadastroPage />
  }
  if (page === 'rdo') {
    return <RdoIndexPage />
  }
  if (page === 'chart') {
    return <ChartIndexPage />
  }
  if (page === 'dashboard') {
    return <DashboardPage />
  }
  if (page === 'efetivo') {
    return <EfetivoIndexPage />
  }
  if (page === 'obra-cadastro') {
    return <ObraCadastroPage />
  }
  if (page === 'obra-index') {
    return <ObraIndexPage />
  }
  if (page === 'empresa-index') {
    return <EmpresaIndexPage />
  }
  if (page === 'colaborador-index') {
    return <ColaboradorIndexPage />
  }
  if (page === 'equipamento-index') {
    return <EquipamentoIndexPage />
  }
  return <CardsPage />
}

export default App
