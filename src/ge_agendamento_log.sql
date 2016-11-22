create table ge_agendamento_log(
 sq_disparo number not null,
 dt_hr_disparo date not null,
 nm_usuario_disparo varchar2(30) not null,
 ds_result_statment clob,
 sq_agendamento number(10),
 ds_agendamento varchar2(4000) not null,
 ds_statment clob not null,
 minutos varchar2(100) not null, 
 horas varchar2(100) not null,
 dias_da_semana varchar2(100) not null,
 dias_do_mes varchar2(100) not null,
 meses varchar2(100) not null);
 
alter table ge_agendamento_log
 move tablespace dad_unicampo_128k;
 
alter table ge_agendamento_log 
  add constraint pk_ge_agendamento_log primary key (sq_disparo)
  using index tablespace ind_unicampo_128k;
  
alter table ge_agendamento_log  
  add constraint fk_agendamento_agendamento_log foreign key (sq_agendamento)
  references ge_agendamento(sq_agendamento);
  
create index fk_agendamento_agendamento_log on ge_agendamento_log(sq_agendamento)
 tablespace ind_unicampo_128k;  
 
create public synonym ge_agendamento_log for ge_agendamento_log;

grant all on ge_agendamento_log to unicoop_geral;

create sequence sq_ge_agendamento_log
increment by 1
start with 1
nocache;  

create public synonym sq_ge_agendamento_log for sq_ge_agendamento_log;

grant all on sq_ge_agendamento_log to unicoop_geral;
/