import { CardsPage } from './pages/CardsPage'
import { EscolherPage } from './pages/EscolherPage'
import { detectOperadorPage } from './route'

function App() {
  const page = detectOperadorPage()
  if (page === 'escolher') {
    return <EscolherPage />
  }
  return <CardsPage />
}

export default App
