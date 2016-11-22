create or replace package pkg_cron is
	function fun_split(p_string in varchar2,
							 p_caracter in varchar2) return dbms_utility.maxname_array;
	procedure prc_dispara_agendamento;
end pkg_cron;
/

create or replace package body pkg_cron is
	function fun_split(p_string in varchar2,
							 p_caracter in varchar2) return dbms_utility.maxname_array is
		va_array dbms_utility.maxname_array;
		va_posicao number := 1;
		va_index number := 0;
		va_string varchar2(32767);
	begin
		va_string := p_string;
		for reg in 1 .. length(va_string)
		loop
			if substr(va_string, va_posicao, 1) = p_caracter then
				va_index := va_index + 1;
				va_array(va_index) := substr(va_string, 1, va_posicao - 1);
				va_string := substr(va_string, va_posicao + 1, 32767);
				va_posicao := 0;
			end if;
			va_posicao := va_posicao + 1;
		end loop;
		va_index := va_index + 1;
		va_array(va_index) := va_string;
	
		return va_array;
	end;

	procedure prc_dispara_agendamento is
		pragma autonomous_transaction;
		array_especifico dbms_utility.maxname_array;
		array_intervalo dbms_utility.maxname_array;
		va_deferido_intervalo number;
		va_deferido number;
		array_erro_disparo dbms_utility.maxname_array;
		array_comandos dbms_utility.maxname_array;
		va_index_cmd number := 0;
		array_sq_agendamento_log dbms_utility.maxname_array;
		array_ds_agendamento_log dbms_utility.maxname_array;
		array_ds_statment_log dbms_utility.maxname_array;
		array_minutos_log dbms_utility.maxname_array;
		array_horas_log dbms_utility.maxname_array;
		array_dias_da_semana_log dbms_utility.maxname_array;
		array_dias_do_mes_log dbms_utility.maxname_array;
		array_meses_log dbms_utility.maxname_array;
	begin
		-- Algoritmo
		for reg_agendamento in (select *
										  from ge_agendamento
										 where st_ativo = 1
										 order by sq_agendamento)
		loop
			va_deferido := null;
			array_erro_disparo.delete;
			for reg in (select meses campo,
									 to_number(to_char(sysdate, 'mm')) momento_atual
							  from ge_agendamento
							 where sq_agendamento = reg_agendamento.sq_agendamento
							union all
							select dias_do_mes,
									 to_number(to_char(sysdate, 'dd'))
							  from ge_agendamento
							 where sq_agendamento = reg_agendamento.sq_agendamento
							union all
							select dias_da_semana,
									 to_number(to_char(sysdate, 'd'))
							  from ge_agendamento
							 where sq_agendamento = reg_agendamento.sq_agendamento
							union all
							select horas,
									 to_number(to_char(sysdate, 'hh24'))
							  from ge_agendamento
							 where sq_agendamento = reg_agendamento.sq_agendamento
							union all
							select minutos,
									 to_number(to_char(sysdate, 'mi'))
							  from ge_agendamento
							 where sq_agendamento = reg_agendamento.sq_agendamento)
			loop
				if va_deferido = 0 then
					exit;
				end if;
				if reg.campo <> '*' then
					if instr(reg.campo, '-') = 0 and
						instr(reg.campo, ',') = 0 then
						if reg.campo = reg.momento_atual then
							va_deferido := 1;
						else
							va_deferido := 0;
						end if;
					else
						array_especifico := fun_split(reg.campo, ',');
						va_deferido_intervalo := 0;
						for index_esp in array_especifico.first .. array_especifico.last
						loop
							if va_deferido_intervalo = 1 then
								exit;
							end if;
							array_intervalo := fun_split(array_especifico(index_esp), '-');
							if array_intervalo.count = 1 then
								if array_especifico(index_esp) = reg.momento_atual then
									va_deferido := 1;
									exit;
								else
									va_deferido := 0;
								end if;
							else
								if reg.momento_atual between array_intervalo(1) and array_intervalo(2) then
									va_deferido := 1;
									va_deferido_intervalo := 1;
								else
									va_deferido := 0;
								end if;
							end if;
						end loop;
					end if;
				else
					va_deferido := 1;
				end if;
			end loop;
		
			-- Evitando troca de contexto
			if va_deferido = 1 then
				va_index_cmd := va_index_cmd + 1;
				array_comandos(va_index_cmd) := to_char(reg_agendamento.ds_statment);
				array_sq_agendamento_log(va_index_cmd) := reg_agendamento.sq_agendamento;
				array_ds_agendamento_log(va_index_cmd) := reg_agendamento.ds_agendamento;
				array_ds_statment_log(va_index_cmd) := reg_agendamento.ds_statment;
				array_minutos_log(va_index_cmd) := reg_agendamento.minutos;
				array_horas_log(va_index_cmd) := reg_agendamento.horas;
				array_dias_da_semana_log(va_index_cmd) := reg_agendamento.dias_da_semana;
				array_dias_do_mes_log(va_index_cmd) := reg_agendamento.dias_do_mes;
				array_meses_log(va_index_cmd) := reg_agendamento.meses;
			end if;
		end loop;
	
		-- Executa os comandos
		for i in array_comandos.first .. array_comandos.last
		loop
			array_erro_disparo(i) := null;
			begin
				execute immediate array_comandos(i);
			exception
				when others then					
					array_erro_disparo(i) := sqlerrm;
			end;
		end loop;
	
		-- Registra LOG de disparo
		forall i in array_sq_agendamento_log.first .. array_sq_agendamento_log.last
			insert into ge_agendamento_log
				(sq_disparo,
				 dt_hr_disparo,
				 nm_usuario_disparo,
				 ds_result_statment,
				 sq_agendamento,
				 ds_agendamento,
				 ds_statment,
				 minutos,
				 horas,
				 dias_da_semana,
				 dias_do_mes,
				 meses)
			values
				(sq_ge_agendamento_log.nextval,
				 sysdate,
				 user,
				 array_erro_disparo(i),
				 array_sq_agendamento_log(i),
				 array_ds_agendamento_log(i),
				 array_ds_statment_log(i),
				 array_minutos_log(i),
				 array_horas_log(i),
				 array_dias_da_semana_log(i),
				 array_dias_do_mes_log(i),
				 array_meses_log(i));
		commit;
	exception
		when others then
			raise_application_error(-20666,'Erro inserindo GE_AGENDAMENTO_LOG na PKG_UTIL.prc_dispara_agendamento:' || chr(10) || sqlerrm);
	end;
end pkg_cron;
/

