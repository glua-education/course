local NAME = 'disconnect_positions.json' -- Одновременно: путь, название и тип файла
local PATH = 'DATA' -- Глобальный путь

if not file.Exists( NAME, PATH ) then file.Write( NAME, '[]' ) end -- Пустая JSON таблица - это []

hook.Add( 'PlayerDisconnected', 'SavePositions', function( ePly )  -- Создаём хук, когда игрок выходит
    local positions = util.JSONToTable( file.Read( NAME, PATH ) ) -- Мы читаем инфу и сразу же форматируем в таблицу
    if not positions then positions = {} end -- Если таблицы не будет, то мы её тупо создадим

    positions[ ePly:SteamID() ] = { pos = ePly:GetPos(), ang = ePly:EyeAngles() } -- Указываем данные: позицию игрока и угол его глаз. Ключ будет SteamID игрока

    file.Write( NAME, util.TableToJSON( positions ) ) -- Записываем сразу же отформатированные в JSON данные (Всю таблицу со всеми игроками, включая нового игрока)
end )

hook.Add( 'PlayerInitialSpawn', 'BackPositions', function( ePly ) -- Создаём хук, когда игрок ВПЕРВЫЕ подключается
    timer.Simple( 0, function() -- Это костыль
        if not IsValid( ePly ) then return end -- Из-за костыля

        local positions = util.JSONToTable( file.Read( NAME, PATH ) ) -- Читаем всю таблицу
        if not positions then return end -- Если таблицы нет, то и париться не надо :)

        local position = positions[ ePly:SteamID() ] -- Таблица есть, тогда находим в ней нашего игрока
        if position then -- Наш игрок есть?? Окей, идём дальше
            local pos, ang = position.pos, position.ang -- Локализируем позицию и угол, чтобы кратко писать и быстро обращаться

            -- Тут немного сложно, дело в том, что JSON форматирует Vector, Color, Angle - как обычные таблицы
            -- И наша задача превратить эти таблицы в нужные нам форматы: Вектор и Угол.
            -- Но мы не будем создавать новые переменные, мы просто в наши же переменные изменим значения
            -- Не нужно бояться этой магией, всё просто. Читаем справа - налево! Мы используем старые pos и ang
            -- И в конце (в самой левой части) мы вкладываем в наши же pos и ang - новые данные
            -- Всё просто: Сначала выполнится самая правая часть, и в конце самая левая.
            pos, ang = Vector( pos[ 1 ], pos[ 2 ], pos[ 3 ] ), Angle( ang[ 1 ], ang[ 2 ], ang[ 3 ] )

            -- Ну а потом, телепортируем игрока и меняем ему взгляд
            ePly:SetPos( pos ) 
            ePly:SetEyeAngles( ang )
        end
    end )
end )
