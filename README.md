# OracleCronSchedule
Projeto PL/SQL (ORACLE) para execução de tarefas agendadas. Baseado no CRON/CRONTAB(UNIX).
Projeto criado devido o precário gerenciamento de JOBS/SCHEDULES do banco de dados ORACLE (10g).

# Como usar o OracleCronSchedule
Para agendar uma tarefa o usuário deve inserir um registro na tabela GE_AGENDAMENTO. Aqui ele preencherá o comando e a frequência com que o mesmo irá ser executado. Há também possibilidade de inativar e ativar tarefas a qualquer momento.

<strong>O preenchimento de cada campo é feito da seguinte maneira:</strong>

- Minutos: informe números de 0 a 59;
- Horas: informe números de 0 a 23, sendo 0 meia-noite;
- Dias do mês: informe números de 0 a 31;
- Mês: informe números de 1 a 12, sendo 1 janeiro e 12 dezembro;
- Dias da semana: informe números de 1 a 7, sendo 1 domingo e 7 sábado;
- Comando: a tarefa que deve ser executada.

No lugar desses valores, você pode informar * (asterisco) para especificar uma execução constante. Por exemplo, se o campo dias do mês conter *, o comando relacionado será executado todos os dias.

Você também pode informar intervalos no preenchimento, separando os números de início e fim através de - (hífen). Por exemplo, se no campo horas for informando 2-5, o comando relacionado será executado às 2, 3, 4 e 5 horas. E se o comando tiver que ser executado às 2 horas, entre 15 e 18 horas e às 22 horas? Basta informar 2,15-18,22. Nestes casos, você separa os parâmetros por vírgula.

<strong>O acompanhamento </strong> da execução de cada processo/tarefa, pode ser visto na tabela GE_AGENDAMENTO_LOG.

# License
Copyright (c) 2016 Linepack
[MIT License] (https://github.com/Linepack/OracleCronSchedule/blob/master/LICENSE)
