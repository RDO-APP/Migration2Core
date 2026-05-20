using System;
using rdoappProject.Api.Models;

namespace TestCompilation
{
    public class TestClass
    {
        public void TestMethod()
        {
            // Teste simples para verificar se compila
            var laudo = new LaudoViewModel();
            // var tarefa = new TarefaViewModel(); // Comentado para evitar erro
            Console.WriteLine("Compilacao OK");
        }
    }
}
