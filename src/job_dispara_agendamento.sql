declare
	va_job number;
begin
	dbms_job.submit(job       => va_job,
					what      => 'begin  pkg_cron.prc_dispara_agendamento; end;',
					next_date => trunc(sysdate,'mi') + 1/1440,
					interval  => 'trunc(sysdate,''mi'') + 1/1440');
	commit;
end;
/