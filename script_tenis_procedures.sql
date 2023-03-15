SET SERVEROUTPUT ON
drop table reservas;
drop table pistas;
drop sequence seq_pistas;

create table pistas (
	nro integer primary key
	);
	
create table reservas (
	pista integer references pistas(nro),
	fecha date,
	hora integer check (hora >= 0 and hora <= 23),
	socio varchar(20),
	primary key (pista, fecha, hora)
	);
	
create sequence seq_pistas;

insert into pistas values (seq_pistas.nextval);
insert into reservas 
	values (seq_pistas.currval, '20/03/2018', 14, 'Pepito');
insert into pistas values (seq_pistas.nextval);
insert into reservas 
	values (seq_pistas.currval, '24/03/2018', 18, 'Pepito');
insert into reservas 
	values (seq_pistas.currval, '21/03/2018', 14, 'Juan');
insert into pistas values (seq_pistas.nextval);
insert into reservas 
	values (seq_pistas.currval, '22/03/2018', 13, 'Lola');
insert into reservas 
	values (seq_pistas.currval, '22/03/2018', 12, 'Pepito');

commit;

create or replace PROCEDURE  pAnularReserva is
    p_socio varchar(20):='Socio 1';
	p_fecha date:=CURRENT_DATE;
	p_hora integer:=12;
	p_pista integer:=1;
    RESERVA_INEXISTENTE exception;
    PRAGMA EXCEPTION_INIT( RESERVA_INEXISTENTE, -20001);
    
begin
	DELETE FROM reservas 
        WHERE
            trunc(fecha) = trunc(p_fecha) AND
            pista = p_pista AND
            hora = p_hora AND
            socio = p_socio;

	if sql%rowcount = 1 then
		commit;
		dbms_output.put_line('Anulacion correctamente ejecutada');
	else
		rollback;
		raise_application_error(-20000, 'Reserva inexistente');
	end if;
exception 
    when others then
    rollback;
    raise; --raise sin especificar la excepción la relanza
end;
/

create or replace PROCEDURE  pReservarPista IS
    p_socio VARCHAR(20):='Socio 1';
    p_fecha DATE:=CURRENT_DATE;
    p_hora INTEGER:=12;
    NO_EXISTEN_PISTAS_LIBRES exception;
    PRAGMA EXCEPTION_INIT( NO_EXISTEN_PISTAS_LIBRES, -20001);
    
    CURSOR vPistasLibres IS
        SELECT nro
        FROM pistas 
        WHERE nro NOT IN (
            SELECT pista
            FROM reservas
            WHERE 
                trunc(fecha) = trunc(p_fecha) AND
                hora = p_hora)
        order by nro;
            
    vPista INTEGER;

BEGIN
    OPEN vPistasLibres;
    FETCH vPistasLibres INTO vPista;
    dbms_output.put_line('Valor de vPistasLibres%FOUND= ' || sys.diutil.bool_to_int(vPistasLibres%FOUND));
    dbms_output.put_line('Valor de vPistasLibres%NOTFOUND= ' || sys.diutil.bool_to_int(vPistasLibres%NOTFOUND));
    IF vPistasLibres%NOTFOUND
    THEN
        --Si el cursor no contiene datos pasaria por aqui y dejaria la transaccion abierta
        dbms_output.put_line('Error Valor de vPistasLibres%FOUND= ' || sys.diutil.bool_to_int(vPistasLibres%FOUND));
        dbms_output.put_line('Error Valor de vPistasLibres%NOTFOUND= ' || sys.diutil.bool_to_int(vPistasLibres%NOTFOUND));
        CLOSE vPistasLibres;
        ROLLBACK;
        raise_application_error(-20001, 'No quedan pistas libres en esa fecha y hora');
    END IF;

    INSERT INTO reservas VALUES (vPista, p_fecha, p_hora, p_socio);
    CLOSE vPistasLibres;
    COMMIT;
    dbms_output.put_line('Reserva ejecutada correctamente');
exception 
    when others then
    rollback;
    raise; --raise sin especificar la excepción la relanza
    
END;
/

/*
<<bloque_anonimo_1>>
declare
    resultado integer;
    CURSOR c_reservas IS SELECT * FROM reservas order by pista;
    v_i reservas%ROWTYPE;
 
begin
 
     resultado := reservarPista( 'Socio 1', CURRENT_DATE, 12 );
     if resultado=1 then
        dbms_output.put_line('Reserva 1: OK');
     else
        dbms_output.put_line('Reserva 1: MAL');
     end if;
     
     --Continua tu solo....
     
     resultado := reservarPista( 'Socio 2', CURRENT_DATE, 13 );
     if resultado=1 then
        dbms_output.put_line('Reserva 2: OK');
     else
        dbms_output.put_line('Reserva 2: MAL');
     end if;
     
     resultado := reservarPista( 'Socio 3', CURRENT_DATE, 14 );
     if resultado=1 then
        dbms_output.put_line('Reserva 3: OK');
     else
        dbms_output.put_line('Reserva 3: MAL');
     end if;
     
     
      
    resultado := anularReserva( 'Socio 1', CURRENT_DATE, 12, 1);
     if resultado=1 then
        dbms_output.put_line('Reserva 1 anulada: OK');
     else
        dbms_output.put_line('Reserva 1 anulada: MAL');
     end if;
  
     resultado := anularReserva( 'Socio 1', date '1920-1-1', 12, 1);
     --Continua tu solo....
    
    dbms_output.put_line('PISTA ' || 'FECHA ' || '    HORA ' || ' SOCIO');
    open c_reservas;
    
    loop
        fetch c_reservas into v_i;
        exit when c_reservas%notfound;

        dbms_output.put_line(v_i.pista || '    ,' || v_i.fecha || ' ,' || v_i.hora || '   ,' || v_i.socio);
    end loop;
    
    CLOSE c_reservas;     
end;
/
*/
create or replace procedure TEST_PROCEDURES_TENIS is
    resultado integer;
    CURSOR c_reservas IS SELECT * FROM reservas order by pista;
    v_i reservas%ROWTYPE;
 
begin
 /*
     resultado := reservarPista( 'Socio 1', CURRENT_DATE, 12 );
     if resultado=1 then
        dbms_output.put_line('Reserva 1: OK');
     else
        dbms_output.put_line('Reserva 1: MAL');
     end if;
     
     --Continua tu solo....
     
     resultado := reservarPista( 'Socio 2', CURRENT_DATE, 13 );
     if resultado=1 then
        dbms_output.put_line('Reserva 2: OK');
     else
        dbms_output.put_line('Reserva 2: MAL');
     end if;
     
     resultado := reservarPista( 'Socio 3', CURRENT_DATE, 14 );
     if resultado=1 then
        dbms_output.put_line('Reserva 3: OK');
     else
        dbms_output.put_line('Reserva 3: MAL');
     end if;
     
     
      
    resultado := anularReserva( 'Socio 1', CURRENT_DATE, 12, 1);
     if resultado=1 then
        dbms_output.put_line('Reserva 1 anulada: OK');
     else
        dbms_output.put_line('Reserva 1 anulada: MAL');
     end if;
  
     resultado := anularReserva( 'Socio 1', date '1920-1-1', 12, 1);
     --Continua tu solo....
    */
    dbms_output.put_line('PISTA ' || 'FECHA ' || '    HORA ' || ' SOCIO');
    
    pReservarPista;
    pAnularReserva;
    
    open c_reservas;
    
    loop
        fetch c_reservas into v_i;
        exit when c_reservas%notfound;

        dbms_output.put_line(v_i.pista || '    ,' || v_i.fecha || ' ,' || v_i.hora || '   ,' || v_i.socio);
    end loop;
    
    CLOSE c_reservas; 
    
    
end;
/


exec TEST_PROCEDURES_TENIS;




