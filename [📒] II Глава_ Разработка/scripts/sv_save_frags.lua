local DB = 'frags'
local Str = sql.SQLStr -- Чтобы быстрее напечатать

sql.Query( 'CREATE TABLE IF NOT EXISTS '..DB..' ( SteamID, Frags, HasOneDeath )' ) -- Если нет таблицы, то создаём её

hook.Add( 'PlayerInitialSpawn', 'SetDB', function( ePly ) 
    if ePly:IsBot() then return end -- Боты нам не нужны!

    local sid = Str( ePly:SteamID() )

    local info = sql.Query( 'SELECT * FROM '..DB..' WHERE SteamID = '..sid )
	if not info then
        -- Будем юзать функцию Format, она работает также, как и string.format, первый аргумент - строка с паттернами, остальные аргументы значения.
        -- С нею легче работать в sql
        -- 1 - SteamID, 2 - 0 фрагов, 3 - false в числа
        local values = Format( '%s, %i, %i', sid, 0, 0 ) -- Мы последнее значение не в булевом виде, а виде числа!

		sql.Query( 'INSERT INTO '..DB..'( SteamID, Frags, HasOneDeath ) VALUES('..values..')' )
	end
end )

hook.Add( 'PlayerDeath', 'AddFragInDB', function( eVictim, _, eAttacker ) 
    if not IsValid( eAttacker ) or not eAttacker:IsPlayer() then return end
    if ( eAttacker == eVictim ) then return end -- Самоубийство не одобряем!

    local sid = Str( eAttacker:SteamID() )
    local has_one_death = sql.QueryValue( 'SELECT HasOneDeath FROM '..DB..' WHERE SteamID = '..sid )
    has_one_death = tobool( has_one_death ) -- Он нам возвращает строку, а мы делаем её в Bool

    if has_one_death then return end -- Если смерть есть у игрока, то не добавляем фраг

    local frags = sql.QueryValue( 'SELECT Frags FROM '..DB..' WHERE SteamID = '..sid )
    frags = tonumber( frags ) + 1
    
    sql.Query( 'UPDATE '..DB..' SET Frags = '..frags.. ' WHERE SteamID = '..sid )

    local sid2 = Str( eVictim:SteamID() ) -- теперь у того, кто умер задаём HasOneDeath
    sql.Query( 'UPDATE '..DB..' SET HasOneDeath = 1 WHERE SteamID = '..sid2 )
end )

local function ResetFrags( ePly )
    if not IsValid( ePly ) or not ePly:IsPlayer() then return end

    local sid = Str( ePly:SteamID() )
    sql.Query( 'DELETR FROM '..DB..' WHERE SteamID = '..sid )

    local values = Format( '%s, %i, %i', sid, 0, 0 )
	sql.Query( 'INSERT INTO '..DB..'( SteamID, Frags, HasOneDeath ) VALUES('..values..')' )
end
