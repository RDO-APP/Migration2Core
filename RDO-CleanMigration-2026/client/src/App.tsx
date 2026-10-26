import { CardsPage } from './pages/CardsPage'
import { EscolherPage } from './pages/EscolherPage'
import { LoginPage } from './pages/LoginPage'
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
  if (page === 'rdo') {
    return <RdoIndexPage />
  }
  return <CardsPage />
}

export default App
