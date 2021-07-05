USE H_Accounting;

DROP PROCEDURE IF EXISTS Team8_BS;

######################################################################
#################### Creating procedure for a B/S ####################
######################################################################

DELIMITER $$

	CREATE PROCEDURE Team8_BS(varCalendarYear YEAR)
	BEGIN
  
		-- Define variables inside of our procedure
        DECLARE varCurrentAsset 	DOUBLE DEFAULT 0;
		DECLARE varCurrentAssets 	DOUBLE DEFAULT 0;
        
		DECLARE varFixedAsset 		DOUBLE DEFAULT 0;
        DECLARE varFixedAssets 		DOUBLE DEFAULT 0;
        
        DECLARE varDeferredAsset 	DOUBLE DEFAULT 0;
		DECLARE varDeferredAssets 	DOUBLE DEFAULT 0;
        
        DECLARE varCurrentLia 		DOUBLE DEFAULT 0;
        DECLARE varCurrentLias 		DOUBLE DEFAULT 0;
        
        DECLARE varLongtermLia 		DOUBLE DEFAULT 0;
		DECLARE varLongtermLias 	DOUBLE DEFAULT 0;
        
        DECLARE varDeferredLia 		DOUBLE DEFAULT 0;
        DECLARE varDeferredLias 	DOUBLE DEFAULT 0;
        
	    DECLARE varEquity 			DOUBLE DEFAULT 0;
        DECLARE varEquitys 			DOUBLE DEFAULT 0;

#################### Calculating values for each line item of the B/S ####################
        
		--  current assets Credit
		SELECT SUM(jeli.credit) INTO varCurrentAsset
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
			WHERE ss.statement_section_code = "CA"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND credit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
	   --  current assets debit
		SELECT SUM(jeli.debit) INTO varCurrentAssets
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
			WHERE ss.statement_section_code = "CA"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND debit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
        -- Fixed Assets credit
        SELECT SUM(jeli.credit) INTO varFixedAsset
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
			WHERE ss.statement_section_code = "FA"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND credit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
		  -- Fixed Assets debit
        SELECT SUM(jeli.debit) INTO varFixedAssets
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
			WHERE ss.statement_section_code = "FA"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND debit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
		
        
        -- Deferred Assets credit
        SELECT SUM(jeli.credit) INTO varDeferredAsset
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
			WHERE ss.statement_section_code = "DA"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND credit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
		-- Deferred Assets debit
        SELECT SUM(jeli.debit) INTO varDeferredAssets
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
			WHERE ss.statement_section_code = "DA"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND debit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
	
		 -- Current liability debit
         SELECT SUM(jeli.debit) INTO varCurrentLia
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
            WHERE ss.statement_section_code = "CL"
				AND balance_sheet_section_id <> 0
				AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND debit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
		
        -- Current liability credit
         SELECT SUM(jeli.credit) INTO varCurrentLias
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
            WHERE ss.statement_section_code = "CL"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND credit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
		
        -- Long term liability debit
         SELECT SUM(jeli.debit) INTO varLongtermLia
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
            WHERE ss.statement_section_code = "LLL"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND debit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
		-- Long term liability credit
         SELECT SUM(jeli.credit) INTO varLongtermLias
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
            WHERE ss.statement_section_code = "LLL"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND credit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
		 -- Deferred liability debit
         SELECT SUM(jeli.debit) INTO varDeferredLia
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
            WHERE ss.statement_section_code = "DL"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND debit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
		-- Deferred liability credit
         SELECT SUM(jeli.credit) INTO varDeferredLias
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
            WHERE ss.statement_section_code = "DL"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND credit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
		                
		 -- Shareholder's equity debit
           SELECT SUM(jeli.debit) INTO varEquity
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
            WHERE ss.statement_section_code = "EQ"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
                AND cancelled              =  0
                AND debit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
                
		-- Shareholder's equity credit
           SELECT SUM(jeli.credit) INTO varEquitys
		    FROM account AS ac
            INNER JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id
            INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
			INNER JOIN journal_entry 	 AS je ON je.journal_entry_id = jeli.journal_entry_id
            WHERE ss.statement_section_code = "EQ"
				AND balance_sheet_section_id <> 0
                AND debit_credit_balanced  <> 0
				AND cancelled              =  0
                AND credit IS NOT NULL
				AND YEAR(je.entry_date) <= varCalendarYear
                GROUP BY statement_section_order, statement_section_code, statement_section;
         
 #################### Creating table to input values into ####################
       
        -- Dropping the `tmp` table where we will input the values
		-- The IF EXISTS is important. Because if the table does not exist the DROP alone would fail
		DROP TABLE IF EXISTS tmp_subas2016_table;
  
		-- Creating the the columns we need
		CREATE TABLE tmp_subas2016_table
		( balance_sheet_line_number VARCHAR(5), 
			label VARCHAR(50), 
			amount VARCHAR(50)
		);
  
   -- Inserting the a header for the report
   INSERT INTO tmp_subas2016_table
		(balance_sheet_line_number, label, amount)
		VALUES ('', 'BALANCE SHEET STATEMENT', "In '000s of USD");
  
    -- Inserting an empty line to create some space between the header and the line items
	INSERT INTO tmp_subas2016_table
		(balance_sheet_line_number, label, amount)
  		VALUES ('', '', '');
    
	-- Inserting values for the B/S
	INSERT INTO tmp_subas2016_table
		(balance_sheet_line_number, label, amount)
  		VALUES 
        (2001, 'Current Assets', 		format((varCurrentAssets - varCurrentAsset)/1000, 2)),
        (2002, 'Fixed Assets', 			format(( varFixedAssets - varFixedAsset)/1000, 2)),
		(2003, 'Deferred Assets', 		format((varDeferredAssets - varDeferredAsset)/1000, 2)),
        (2004, 'Total Assets', 			format((varCurrentAssets - varCurrentAsset
										+ varFixedAssets - varFixedAsset
										+ varDeferredAssets - varDeferredAsset )/1000,2)),
		(' ', ' ', ' '),
        (2005, 'Current Liability', 	format((varCurrentlias - varCurrentLia)/1000, 2)),
        (2006, 'Long Term Liability', 	format((varLongtermlias - varLongtermLia)/1000 , 2)),
        (2007, 'Deferred Liability', 	format((varDeferredLias - varDeferredLia)/1000,2)),
        (2008, 'Total Liability', 		format((varCurrentlias - varCurrentLia  
										+ varLongtermlias - varLongtermLia
										+ varDeferredLias - varDeferredLia )/1000,2)),
		(' ', ' ', ' '),
        (2009, 'Equity', 					format((varEquitys - varEquity)/1000, 2)),
        (' ', ' ', ' '),
        (2010, 'Total liability and equity', format((varCurrentlias - varCurrentLia  
											+ varLongtermlias - varLongtermLia
											+ varDeferredLias - varDeferredLia 
											+ varEquitys - varEquity)/1000,2));
        
    
	END $$
DELIMITER ;

############################################################################
#################### Calling all B/S for several years #####################
############################################################################

# Balance Sheet For 2015
#CALL Team8_BS (2015);
#SELECT * FROM tmp_subas2016_table;

# Balance Sheet for 2016
CALL Team8_BS (2016);
SELECT * FROM tmp_subas2016_table;

# Balance Sheet For 2017
#CALL Team8_BS (2017);
#SELECT * FROM tmp_subas2016_table;

# Balance Sheet For 2018
#CALL Team8_BS (2018);
#SELECT * FROM tmp_subas2016_table;

# Balance Sheet for 2019
#CALL Team8_BS (2019);
#SELECT * FROM tmp_subas2016_table;