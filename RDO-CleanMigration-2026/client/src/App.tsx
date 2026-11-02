import { CardsPage } from './pages/CardsPage'
import { ChartIndexPage } from './pages/ChartIndexPage'
import { DashboardPage } from './pages/DashboardPage'
import { EscolherPage } from './pages/EscolherPage'
import { LoginPage } from './pages/LoginPage'
import { RdoCadastroPage } from './pages/RdoCadastroPage'
import { RdoIndexPage } from './pages/RdoIndexPage'
import { detectOperadorPage } from './route'

function App() {
  const page = detectOperadorPage()
  if (page === 'login') {
    return <LoginPage />
  }
  if (page === 'escolher') {
    return <EscolherPage />
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
  return <CardsPage />
}

export default App
