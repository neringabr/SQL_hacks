-- 1 case: all entries are written to `dbo.a`
drop table if exists  dbo.a
exec [dbo].test1 50, 60, 70 
select * from dbo.a --- id: 50, 60, 70

-- 2 case: `dbo.a` is created and then with rollback is deleted
drop table if exists  dbo.a
exec [dbo].test1 'a', 60, 70 
select * from dbo.a  --- Invalid object name 'dbo.a'

-- 3 case: `dbo.a` should exist with two values 50, 60
drop table if exists  dbo.a
exec [dbo].test1 50, 60, 'f70' 
select * from dbo.a   --- id: 50, 60