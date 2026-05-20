// app.filters.js

angular.module('app')
    .filter('lookup', function () {
        // Este é o 'factory function' do seu filtro
        return function (id, list) {

            if (!list || !id)
                return ' — ';

            // Usa == para permitir a comparação entre string e number, comum em IDs
            for (var i = 0; i < list.length; i++) {
                if (list[i].id == id) {
                    return list[i].nome;
                }
            } 
            return ' — ';
        };
    });


angular.module('app').filter('simNao', function () {
    return function (valor) {
        return valor ? 'Sim' : 'Não';
    };
});