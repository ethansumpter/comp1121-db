/*
@author Ethan Sumpter

This is an sql file to put your queries for SQL coursework. 
You can write your comment in sqlite with -- or /* * /

To read the sql and execute it in the sqlite, simply
type .read sqlcwk.sql on the terminal after sqlite3 musicstore.db.
*/

/* =====================================================
   WARNNIG: DO NOT REMOVE THE DROP VIEW
   Dropping existing views if exists
   =====================================================
*/
DROP VIEW IF EXISTS vNoCustomerEmployee; 
DROP VIEW IF EXISTS v10MostSoldMusicGenres; 
DROP VIEW IF EXISTS vTopAlbumEachGenre; 
DROP VIEW IF EXISTS v20TopSellingArtists; 
DROP VIEW IF EXISTS vTopCustomerEachGenre; 

/*
============================================================================
Task 1: Complete the query for vNoCustomerEmployee.
DO NOT REMOVE THE STATEMENT "CREATE VIEW vNoCustomerEmployee AS"
============================================================================
*/
CREATE VIEW vNoCustomerEmployee AS
SELECT EmployeeId,
       FirstName,
       LastName,
       Title
FROM employees
WHERE EmployeeId NOT IN (
        SELECT DISTINCT SupportRepId
        FROM customers
      );

/*
============================================================================
Task 2: Complete the query for v10MostSoldMusicGenres
DO NOT REMOVE THE STATEMENT "CREATE VIEW v10MostSoldMusicGenres AS"
============================================================================
*/
CREATE VIEW v10MostSoldMusicGenres AS
SELECT genres.Name AS Genre,
       SUM(invoice_items.Quantity) AS Sales
FROM genres
JOIN tracks ON genres.GenreId = tracks.GenreId
JOIN invoice_items ON tracks.TrackId = invoice_items.TrackId
GROUP BY genres.Name
ORDER BY Sales DESC
LIMIT 10;

/*
============================================================================
Task 3: Complete the query for vTopAlbumEachGenre
DO NOT REMOVE THE STATEMENT "CREATE VIEW vTopAlbumEachGenre AS"
============================================================================
*/
CREATE VIEW vTopAlbumEachGenre AS
WITH GenreSales AS (
   SELECT genres.Name AS Genre,
          albums.Title AS Album,
          artists.Name AS Artist,
          SUM(invoice_items.Quantity) AS Sales
   FROM genres
   JOIN tracks ON genres.GenreId = tracks.GenreId
   JOIN invoice_items ON tracks.TrackId = invoice_items.TrackId
   JOIN albums ON albums.AlbumId = tracks.AlbumId
   JOIN artists ON artists.ArtistId = albums.ArtistId
   GROUP BY genres.GenreId, albums.AlbumId
   ORDER BY Sales DESC
),
-- Selects the top selling album from the grouped data
MaxGenreSales AS (
   SELECT Genre,
          MAX(Sales) AS MaxSales
   FROM GenreSales
   GROUP BY Genre
)
SELECT GenreSales.Genre,
       GenreSales.Album,
       GenreSales.Artist,
       GenreSales.Sales
FROM GenreSales
JOIN MaxGenreSales ON (GenreSales.Genre = MaxGenreSales.Genre)
                  AND (GenreSales.Sales = MaxGenreSales.MaxSales);


/*
============================================================================
Task 4: Complete the query for v20TopSellingArtists
DO NOT REMOVE THE STATEMENT "CREATE VIEW v20TopSellingArtists AS"
============================================================================
*/

CREATE VIEW v20TopSellingArtists AS
SELECT artists.Name AS Artist,
       COUNT(DISTINCT albums.AlbumId) AS TotalAlbum,
       SUM(invoice_items.Quantity) AS TrackSold
FROM invoice_items
JOIN tracks ON invoice_items.TrackId = tracks.TrackId
JOIN albums ON tracks.AlbumId = albums.AlbumId
JOIN artists ON albums.ArtistId = artists.ArtistId
GROUP BY artists.ArtistId
ORDER BY TrackSold DESC
LIMIT 20;


/*
============================================================================
Task 5: Complete the query for vTopCustomerEachGenre
DO NOT REMOVE THE STATEMENT "CREATE VIEW vTopCustomerEachGenre AS" 
============================================================================
*/
CREATE VIEW vTopCustomerEachGenre AS
WITH CustSales AS (
   SELECT genres.Name AS Genre,
         (customers.FirstName || ' ' || customers.LastName) AS TopSpender,
         ROUND(SUM(invoice_items.Quantity * invoice_items.UnitPrice),2) AS TotalSpending
   FROM invoice_items
   JOIN invoices ON invoice_items.InvoiceId = invoices.InvoiceId
   JOIN customers ON invoices.CustomerId = customers.CustomerId
   JOIN tracks ON invoice_items.TrackId = tracks.TrackId
   JOIN genres ON tracks.GenreId = genres.GenreId
   GROUP BY genres.GenreId, customers.CustomerId
   ORDER BY TotalSpending DESC
),
-- Selects the top spending amount from the grouped data
MaxCustSales AS (
   SELECT Genre,
          MAX(TotalSpending) AS MaxTotalSpending
   FROM CustSales
   GROUP BY Genre
)
SELECT CustSales.Genre,
       CustSales.TopSpender,
       CustSales.TotalSpending
FROM CustSales
JOIN MaxCustSales ON (CustSales.Genre = MaxCustSales.Genre)
                 AND (CustSales.TotalSpending = MaxCustSales.MaxTotalSpending)
ORDER BY CustSales.Genre ASC;

SELECT * FROM vTopCustomerEachGenre;