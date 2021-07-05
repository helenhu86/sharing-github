-- Picking the database to be used
USE H_Accounting;

-- Dropping any other procedures if any
DROP PROCEDURE IF EXISTS Team8_PandL;

######################################################################
#################### Creating procedure for a P&L ####################
######################################################################

DELIMITER $$

	CREATE PROCEDURE Team8_PandL(varCalendarYear YEAR)
	BEGIN
  
  		-- Defining variables inside our procedure
		DECLARE varTotalRevenues 	DOUBLE DEFAULT 0;
        DECLARE VARTotalCOGs 		DOUBLE DEFAULT 0;
		DECLARE varTotalReturns 	DOUBLE DEFAULT 0;
        DECLARE varAdminexpenses 	DOUBLE DEFAULT 0;
        DECLARE varSellingexpenses 	DOUBLE DEFAULT 0;
        DECLARE varOtherincome 		DOUBLE DEFAULT 0;
        DECLARE varOtherexpenses 	DOUBLE DEFAULT 0;
        DECLARE varIncometax        DOUBLE DEFAULT 0;
        DECLARE varOthertax         DOUBLE DEFAULT 0;
        
#################### Calculating values for each line item of the P&L ####################

		--  Calculating the value of the sales 
		SELECT SUM(jeli.credit) INTO varTotalRevenues
		
			FROM journal_entry_line_item AS jeli	
				INNER JOIN account 				AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "REV"
				AND profit_loss_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
				AND YEAR(je.entry_date) = varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
        -- Calculating the value Returns, Refunds, Discounts
		SELECT SUM(jeli.credit) INTO varTotalReturns
        
        
			FROM journal_entry_line_item AS jeli		
				INNER JOIN account 				AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "RET"
				AND profit_loss_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
				AND YEAR(je.entry_date) = varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
        
        -- Calculating the value COGS
		SELECT SUM(jeli.debit) INTO VARTotalCOGs
		
			FROM journal_entry_line_item AS jeli		
				INNER JOIN account 				AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "COGS"
				AND profit_loss_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
				AND YEAR(je.entry_date) = varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
		 -- Calculating the value Admin expenses
		SELECT SUM(jeli.debit) INTO varAdminexpenses        
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 				AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "GEXP"
				AND profit_loss_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
				AND YEAR(je.entry_date) = varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
		 -- Calculating the value Selling expenses
		SELECT SUM(jeli.debit) INTO varSellingexpenses		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 				AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "SEXP"
				AND profit_loss_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
				AND YEAR(je.entry_date) = varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
		 -- Calculating the value OTHER INCOME
		SELECT SUM(jeli.credit) INTO varOtherincome		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 				AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "OI"
				AND profit_loss_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
				AND YEAR(je.entry_date) = varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
		 -- Calculating the value Other expenses
		SELECT SUM(jeli.debit) INTO varOtherexpenses		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 				AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "OEXP"
				AND profit_loss_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
				AND YEAR(je.entry_date) = varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
		
        --  Calculating the value of income tax
		SELECT SUM(jeli.debit) INTO varIncometax
		
			FROM journal_entry_line_item AS jeli	
				INNER JOIN account 				AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "INCTAX"
				AND profit_loss_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
				AND YEAR(je.entry_date) = varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
		   --  Calculating the value of Other tax
		SELECT SUM(jeli.debit) INTO varOthertax
		
			FROM journal_entry_line_item AS jeli	
				INNER JOIN account 				AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "OTHTAX"
				AND profit_loss_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
				AND YEAR(je.entry_date) = varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
                
        
 #################### Creating table to input values into ####################
       
        -- Dropping the `tmp` table where we will input the values
		-- The IF EXISTS is important. Because if the table does not exist the DROP alone would fail
		DROP TABLE IF EXISTS tmp_subas2016_table;
  
		-- Creating the the columns we need
		CREATE TABLE tmp_subas2016_table
		( profit_loss_line_number VARCHAR(5), 
			label VARCHAR(50), 
			amount VARCHAR(50)
		);
  
  -- Inserting the a header for the report
  INSERT INTO tmp_subas2016_table
		(profit_loss_line_number, label, amount)
		VALUES ('', 'PROFIT AND LOSS STATEMENT', "In '000s of USD");
  
  -- Inserting an empty line to create some space between the header and the line items
	INSERT INTO tmp_subas2016_table
		(profit_loss_line_number, label, amount)
  		VALUES ('', '', '');
    
	-- Inserting values for the P&L
	INSERT INTO tmp_subas2016_table
		(profit_loss_line_number, label, amount)
        
  		VALUES 
        (1001, 'Total Revenues', format(varTotalRevenues / 1000, 2)),
        (1002, 'Returns, Refund, Discounts', format(varTotalReturns / 1000, 2)),
		(1003, 'Total Costs of Goods Sold', format(VARTotalCOGs / 1000, 2)),
        (1004, 'Gross Profit', format((varTotalRevenues / 1000 - VARTotalCOGs / 1000 - varTotalReturns / 1000),2)),
        (' ', ' ', ' '),
        (1005, 'Administrative Expenses', format(varAdminexpenses / 1000, 2)),
        (1006, 'Selling Expenses', format(varSellingexpenses / 1000, 2)),
        (1007, 'Net Operating Income', format((varTotalRevenues / 1000 - VARTotalCOGs / 1000 - varTotalReturns / 1000 
                                              - varAdminexpenses / 1000 - varSellingexpenses / 1000),2)),
        (' ', ' ', ' '),
        (1008, 'Other Income', format(varOtherincome / 1000, 2)),
        (1009, 'Other Expenses', format(varOtherexpenses / 1000, 2)),
        (1010, 'Net Other Income', format((varOtherincome / 1000 - varOtherexpenses / 1000),2)),
        (1011, 'Profit Before Tax', format((varTotalRevenues / 1000 - VARTotalCOGs / 1000 - varTotalReturns / 1000 
                                          - varAdminexpenses / 1000 - varSellingexpenses / 1000 + 
                                           varOtherincome / 1000 - varOtherexpenses / 1000 ),2)),
        (' ', ' ', ' '),
        (1012, 'Corporation Tax', format((varIncometax / 1000 + varOthertax / 1000), 2)),
        (1013, 'Net Income', format((varTotalRevenues / 1000 - VARTotalCOGs / 1000 - varTotalReturns / 1000 
                                          - varAdminexpenses / 1000 - varSellingexpenses / 1000 + 
                                           varOtherincome / 1000 - varOtherexpenses / 1000 -
                                          varIncometax / 1000 - varOthertax / 1000) , 2));
	END $$
DELIMITER ;


########################################################
########## Calling all P&Ls for several years ##########
########################################################

# P&L For 2015
#CALL Team8_PandL(2015);
#SELECT * FROM tmp_subas2016_table;

# P&L for 2016
CALL Team8_PandL(2016);
SELECT * FROM tmp_subas2016_table;

#P&L For 2017
#CALL Team8_PandL(2017);
#SELECT * FROM tmp_subas2016_table;

# P&L For 2018
#CALL Team8_PandL(2018);
#SELECT * FROM tmp_subas2016_table;

# P&L for 2019
#CALL Team8_PandL(2019);
#SELECT * FROM tmp_subas2016_table;