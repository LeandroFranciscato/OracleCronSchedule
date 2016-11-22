create table ge_agendamento(
 sq_agendamento number(10),
 ds_agendamento varchar2(4000) not null,
 ds_statment clob not null,
 minutos varchar2(100) not null, 
 horas varchar2(100) not null,
 dias_da_semana varchar2(100) not null,
 dias_do_mes varchar2(100) not null,
 meses varchar2(100) not null,
 dt_usuinc date not null,
 nm_usuinc varchar2(30) not null,
 dt_usualt date,
 nm_usualt varchar2(30),
 st_ativo number(1) check (st_ativo in (0,1)) not null );
 
 
alter table ge_agendamento
move tablespace dad_unicampo_128k;


alter table ge_agendamento
  add constraint pk_geagendamento primary key (sq_agendamento)
  using index tablespace ind_unicampo_128k;
  

create public synonym ge_agendamento for ge_agendamento;


grant all on ge_agendamento to unicoop_geral; 

comment on column ge_agendamento.minutos is 'informe n�meros de 0 a 59';
comment on column ge_agendamento.horas is 'informe n�meros de 0 a 23, sendo 0 Meia Noite';
comment on column ge_agendamento.dias_da_semana is 'informe n�meros de 1 a 7, sendo 1 Domingo e 7 S�bado.';
comment on column ge_agendamento.dias_do_mes is 'informe n�meros de 1 a 31';
comment on column ge_agendamento.meses is 'informe n�meros de 1 a 12, sendo 1 Janeiro e 12 Dezembro';
comment on column ge_agendamento.ds_agendamento is 'Aten��o!!! No lugar desses valores, voc� pode informar * (asterisco) para especificar uma execu��o constante. 
Por exemplo, se o campo dias do m�s conter *, o comando relacionado ser� executado todos os dias. 
Voc� tamb�m pode informar intervalos no preenchimento, separando os n�meros de in�cio e fim atrav�s de - (h�fen). 
Por exemplo, se no campo horas for informando 2-5, o comando relacionado ser� executado �s 2, 3, 4 e 5 horas. 
E se o comando tiver que ser executado �s 2 horas, entre 15 e 18 horas e �s 22 horas? Basta informar 2,15-18,22. 
Nestes casos, voc� separa os par�metros por v�rgula.';
 
create sequence sq_ge_agendamento 
increment by 1 
start with 1
nocache;

create public synonym sq_ge_agendamento for sq_ge_agendamento;

grant all on sq_ge_agendamento to unicoop_geral;
/
