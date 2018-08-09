create proc [csb].[Get_CargasQueryForSecurityTreeview]
as
      select distinct rowID='CargasQuery' --+ convert(varchar(50), CargasQueryFavoriteIdentifier)
            ,parentID='CargasQuery'
            ,nodeValue= ''--convert(varchar(50), CargasQueryFavoriteIdentifier)
            ,displayValue= ''--Name
            ,linkValue=''     --convert(varchar(50), CargasQueryFavoriteIdentifier) + '&p=CargasQuery'  --type=printPreview, name='
            ,screenValue='ResourceSecurity'
            ,Level = 2
            ,orderby = ''--Name
--    from csiCargasQueryFavorite
      where 1=0
;