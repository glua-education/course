SWEP.PrintName      = 'Стрелятель Стульями'
SWEP.Author	        = 'loglogloglog'
SWEP.Instructions	= 'ЛКМ - стрельнуть стулом' -- Инструкция к оружию, если у вас стоит стандартный Weapon Selector, то при наводке на оружия, всплывает название, автор и инструкция.

SWEP.Spawnable = true
SWEP.AdminOnly = false

-- Заполняем первичные патроны
SWEP.Primary.ClipSize		= -1 
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true -- Автоматика, то есть достаточно зажать кнопку мыши
SWEP.Primary.Ammo		    = "none"

-- Заполняем вторичные патроны, они нам не нужны
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = "none"

SWEP.Weight			    = 5 -- Вес оружия
SWEP.AutoSwitchTo		= false 
SWEP.AutoSwitchFrom		= false

SWEP.Slot			    = 1 -- В каком слоту оружейного инвентаря
SWEP.SlotPos			= 2 -- На какой позиций?
SWEP.DrawAmmo			= false -- Нам не нужно показывать патроны
SWEP.DrawCrosshair		= true -- Нам нужно показать прицел

-- View и World модельки, это архаизм, пришедший с древних игр, вам достаточно лишь 1 раз понять разницу и всё.
SWEP.ViewModel			= "models/weapons/v_pistol.mdl" -- Указываем View модельку, которую будем видеть лишь на клиенте (держим в руках)
SWEP.WorldModel			= "models/weapons/w_pistol.mdl" -- Указываем World модельку, которую будут видеть все (что у вас в руках)

SWEP.ShootSound = Sound( "Metal.SawbladeStick" ) -- О да, звук выстрела :)

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack() -- Первичная атака
	self:SetNextPrimaryFire( CurTime() + 0.5 ) -- Указываем задержку для первичной атаки (это ЛКМ)

	local owner = self:GetOwner() -- Тот, кто держит оружие
	if not IsValid( owner ) then return end -- Проверяем, игрок существует? Если нет, то ничего не будет

	self:EmitSound( self.ShootSound ) -- Здесь self выступает само оружие, и оно воспроизводит звук, который мы указали ранее
 
	if CLIENT then return end -- Дальше клиент нам не нужен, пойдут серверные функций

	local ent = ents.Create( 'prop_physics' ) -- А вот сама функция по созданию Энтити, создаём обычный проп (НЕ СПАВНИМ)
	ent:SetModel( 'models/props_c17/FurnitureChair001a.mdl' ) -- Задаём модельку перед спавном

	local aimvec = owner:GetAimVector() -- Вычисляем направления игрока
    local pos = aimvec * 16 -- берём направление игрока и ещё умножаем чуть вперёд
	pos:Add( owner:EyePos() ) -- Добавляем к позиций ещё позицию глаз игрока

	ent:SetPos( pos ) -- После этих махинаций с позициями, задаём позицию
	ent:SetAngles( owner:EyeAngles() ) -- Угол очень просто, по углу глаза игрока, то есть по взгляду
	ent:Spawn() -- Ну и спавним наш стул
 
	aimvec:Mul( 100 ) -- Дальше берём направление игрока и уже умножаем на 100
	aimvec:Add( VectorRand( -10, 10 ) ) -- И добавляем рандомно от -10 до 10 значение

    local phys = ent:GetPhysicsObject() -- берём физику
	phys:ApplyForceCenter( aimvec ) -- И накладываем силу на физику этой энтити, чтобы она полетела
 
	timer.Simple( 10, function() -- Задаём таймер 10 секундный
        if IsValid( ent ) then ent:Remove() end -- Если через 10 секунд энтити существует, то удаляем её
    end )
end