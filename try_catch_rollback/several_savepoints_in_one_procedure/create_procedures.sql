-- This is a stored procedure named "inner_insert1" that takes one input 
-- parameter of type nvarchar with a length of 50 characters.
create procedure [dbo].inner_insert1 @value nvarchar(50)
as begin

	insert into dbo.a 
	select @value

end

GO;

-- This stored procedure takes three values and inserts them into `dbo.a` using two transactions
create procedure [dbo].test1 @value1 nvarchar(50), @value2 nvarchar(50), @value3 nvarchar(50)
AS 
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
	BEGIN TRANSACTION T2
	
	-- Create a table called dbo.a with a single column called id
	create table dbo.a (
		id int
	)
	PRINT 'Starting T2'

	-- Check if `dbo.a` exists
	
	IF (SELECT COUNT(*)
		FROM information_schema.tables
		WHERE table_name = 'a') > 0
	BEGIN
		print 'Table "dbo.a" is created'
	END

	-- Save the current state of the transaction in case it needs to be rolled back
	SAVE TRANSACTION T2
	
	-- Call the inner_insert1 stored procedure to insert @value1 and @value2 into `dbo.a`
	exec [dbo].inner_insert1 @value1
	exec [dbo].inner_insert1 @value2
	
	declare @count_entries nvarchar(8) = (select COUNT(*) from dbo.a)
	print 'Count of entries in table "dbo.a" is: ' + @count_entries

	COMMIT TRANSACTION T2;

	PRINT 'Starting T3'
	BEGIN TRANSACTION T3
	-- Save the current state of the transaction in case it needs to be rolled back
	SAVE TRANSACTION T3
		
	-- Call the inner_insert1 stored procedure to insert @value3 into `dbo.a`
	exec [dbo].inner_insert1 @value3
	PRINT 'Committing T3'

	COMMIT TRANSACTION T3;

	-- Catch any errors that occur in the try block
	END TRY 

	-- If an error occurs, roll back any open transactions, retrieve information about the error, and raise an error
	BEGIN catch  
		IF @@TRANCOUNT > 0  
		ROLLBACK TRANSACTION  
		DECLARE  @ErrorMessage  NVARCHAR(4000),  
				 @ErrorSeverity INT,    
				 @ErrorState    INT;    
  
		SELECT     
			@ErrorMessage  = ERROR_MESSAGE(),    
			@ErrorSeverity = ERROR_SEVERITY(),   
			@ErrorState    = ERROR_STATE();   
           
		SET @ErrorMessage=@ErrorMessage   
  
		RAISERROR (@ErrorMessage,  -- Message text.    
				   @ErrorSeverity, -- Severity.    
				   @ErrorState     -- State.    
				   ); 
	END CATCH;

END
