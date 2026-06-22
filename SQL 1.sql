
create table if not exists gym_members(
    id bigserial primary key,
    name text not null,
    phone text unique,
    monthly_fee numeric(12,2) default 0,
    plan text,
    join_date date,
    expiry_date date,
    status text default 'ACTIVE',
    created_at timestamptz default now()
);

create table if not exists gym_payments(
    id bigserial primary key,
    member_id bigint references gym_members(id) on delete cascade,
    amount numeric(12,2) default 0,
    payment_date date,
    created_at timestamptz default now()
);

create table if not exists gym_users(
    id bigserial primary key,
    username text not null unique,
    password text not null check (password ~ '^[0-9]+$'),
    role text not null check (role in ('owner','staff','member')),
    display_name text not null,
    member_id bigint references gym_members(id) on delete cascade,
    created_at timestamptz default now()
);

create table if not exists gym_workouts(
    id bigserial primary key,
    member_id bigint not null references gym_members(id) on delete cascade,
    day_no integer default 1,
    focus text,
    name text not null,
    type text not null check (type in ('strength','cardio')),
    target_weight numeric(12,2),
    target_reps integer,
    target_rounds integer,
    target_time_minutes numeric(12,2),
    actual_weight numeric(12,2),
    actual_reps integer,
    actual_rounds integer,
    actual_time_minutes numeric(12,2),
    done boolean default false,
    done_at timestamptz,
    demo_url text,
    instructions text,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

create table if not exists gym_workout_templates(
    id bigserial primary key,
    day_no integer not null,
    focus text not null,
    name text not null,
    type text not null default 'strength' check (type in ('strength','cardio')),
    target_weight numeric(12,2),
    target_reps integer,
    target_rounds integer,
    target_time_minutes numeric(12,2),
    demo_url text,
    instructions text,
    created_at timestamptz default now(),
    unique(day_no,name)
);

create table if not exists gym_workout_logs(
    id bigserial primary key,
    workout_id bigint not null references gym_workouts(id) on delete cascade,
    member_id bigint not null references gym_members(id) on delete cascade,
    actual_weight numeric(12,2),
    actual_reps integer,
    actual_rounds integer,
    actual_time_minutes numeric(12,2),
    completed_at timestamptz not null default now(),
    created_at timestamptz default now()
);

create table if not exists gym_attendance(
    id bigserial primary key,
    member_id bigint not null references gym_members(id) on delete cascade,
    attendance_date date not null default current_date,
    check_in_time timestamptz not null default now(),
    marked_by text,
    created_at timestamptz default now()
);

alter table gym_members enable row level security;
alter table gym_payments enable row level security;
alter table gym_users enable row level security;
alter table gym_workouts enable row level security;
alter table gym_workout_templates enable row level security;
alter table gym_workout_logs enable row level security;
alter table gym_attendance enable row level security;

create policy "Allow all gym_members"
on gym_members
for all
using (true)
with check (true);

create policy "Allow all gym_payments"
on gym_payments
for all
using (true)
with check (true);

create policy "Allow all gym_users"
on gym_users
for all
using (true)
with check (true);

create policy "Allow all gym_workouts"
on gym_workouts
for all
using (true)
with check (true);

create policy "Allow all gym_workout_templates"
on gym_workout_templates
for all
using (true)
with check (true);

create policy "Allow all gym_workout_logs"
on gym_workout_logs
for all
using (true)
with check (true);

create policy "Allow all gym_attendance"
on gym_attendance
for all
using (true)
with check (true);

create index if not exists idx_gym_members_phone
on gym_members(phone);

create index if not exists idx_gym_members_name
on gym_members(name);

create index if not exists idx_gym_payments_date
on gym_payments(payment_date);

create index if not exists idx_gym_users_username
on gym_users(username);

create index if not exists idx_gym_users_member
on gym_users(member_id);

create index if not exists idx_gym_workouts_member
on gym_workouts(member_id);

create index if not exists idx_gym_workouts_done
on gym_workouts(done);

alter table gym_workouts
add column if not exists day_no integer default 1;

alter table gym_workouts
add column if not exists focus text;

alter table gym_workouts
add column if not exists demo_url text;

alter table gym_workouts
add column if not exists instructions text;

create index if not exists idx_gym_workouts_day
on gym_workouts(day_no);

create index if not exists idx_gym_workout_templates_day
on gym_workout_templates(day_no);

alter table gym_workout_templates
add column if not exists demo_url text;

alter table gym_workout_templates
add column if not exists instructions text;

create index if not exists idx_gym_workout_logs_member
on gym_workout_logs(member_id);

create index if not exists idx_gym_workout_logs_workout
on gym_workout_logs(workout_id);

create index if not exists idx_gym_workout_logs_completed
on gym_workout_logs(completed_at);

create index if not exists idx_gym_attendance_member
on gym_attendance(member_id);

create index if not exists idx_gym_attendance_time
on gym_attendance(check_in_time);

insert into gym_users(username,password,role,display_name)
values
('OWNER','1234','owner','GYM OWNER'),
('STAFF','5678','staff','GYM STAFF')
on conflict (username) do update set
password = excluded.password,
role = excluded.role,
display_name = excluded.display_name;

insert into gym_workout_templates(day_no,focus,name,type)
values
(1,'PUSH FOCUS - CHEST, SHOULDERS, TRICEPS','BARBELL OR DUMBBELL BENCH PRESS','strength'),
(1,'PUSH FOCUS - CHEST, SHOULDERS, TRICEPS','CABLE CROSSOVERS','strength'),
(1,'PUSH FOCUS - CHEST, SHOULDERS, TRICEPS','SEATED DUMBBELL PRESS','strength'),
(1,'PUSH FOCUS - CHEST, SHOULDERS, TRICEPS','LATERAL RAISES','strength'),
(1,'PUSH FOCUS - CHEST, SHOULDERS, TRICEPS','TRICEP ROPE PUSHDOWNS','strength'),
(1,'PUSH FOCUS - CHEST, SHOULDERS, TRICEPS','SKULL CRUSHERS','strength'),
(2,'PULL FOCUS - BACK, BICEPS','PULL-UPS','strength'),
(2,'PULL FOCUS - BACK, BICEPS','LAT PULLDOWNS','strength'),
(2,'PULL FOCUS - BACK, BICEPS','SEATED CABLE ROWS','strength'),
(2,'PULL FOCUS - BACK, BICEPS','BARBELL CURLS','strength'),
(2,'PULL FOCUS - BACK, BICEPS','HAMMER CURLS','strength'),
(3,'LEGS FOCUS - QUADS, HAMSTRINGS, GLUTES, CALVES','BARBELL SQUATS','strength'),
(3,'LEGS FOCUS - QUADS, HAMSTRINGS, GLUTES, CALVES','LEG PRESS','strength'),
(3,'LEGS FOCUS - QUADS, HAMSTRINGS, GLUTES, CALVES','LUNGES','strength'),
(3,'LEGS FOCUS - QUADS, HAMSTRINGS, GLUTES, CALVES','ROMANIAN DEADLIFTS','strength'),
(3,'LEGS FOCUS - QUADS, HAMSTRINGS, GLUTES, CALVES','SEATED LEG CURLS','strength'),
(3,'LEGS FOCUS - QUADS, HAMSTRINGS, GLUTES, CALVES','STANDING OR SEATED CALF RAISES','strength'),
(4,'PUSH FOCUS - CHEST, SHOULDERS, TRICEPS','INCLINE DUMBBELL PRESS','strength'),
(4,'PUSH FOCUS - CHEST, SHOULDERS, TRICEPS','CHEST FLYS','strength'),
(4,'PUSH FOCUS - CHEST, SHOULDERS, TRICEPS','STANDING OVERHEAD PRESS','strength'),
(4,'PUSH FOCUS - CHEST, SHOULDERS, TRICEPS','REVERSE PEC DECK','strength'),
(4,'PUSH FOCUS - CHEST, SHOULDERS, TRICEPS','OVERHEAD DUMBBELL EXTENSIONS','strength'),
(4,'PUSH FOCUS - CHEST, SHOULDERS, TRICEPS','TRICEP DIPS','strength'),
(5,'PULL FOCUS - BACK, BICEPS','DEADLIFTS','strength'),
(5,'PULL FOCUS - BACK, BICEPS','T-BAR ROWS','strength'),
(5,'PULL FOCUS - BACK, BICEPS','CLOSE-GRIP PULLDOWNS','strength'),
(5,'PULL FOCUS - BACK, BICEPS','PREACHER CURLS','strength'),
(5,'PULL FOCUS - BACK, BICEPS','ALTERNATING DUMBBELL CURLS','strength'),
(6,'LEGS FOCUS - QUADS, HAMSTRINGS, GLUTES, CALVES','FRONT SQUATS','strength'),
(6,'LEGS FOCUS - QUADS, HAMSTRINGS, GLUTES, CALVES','BULGARIAN SPLIT SQUATS','strength'),
(6,'LEGS FOCUS - QUADS, HAMSTRINGS, GLUTES, CALVES','LYING LEG CURLS','strength'),
(6,'LEGS FOCUS - QUADS, HAMSTRINGS, GLUTES, CALVES','GLUTE BRIDGES','strength'),
(6,'LEGS FOCUS - QUADS, HAMSTRINGS, GLUTES, CALVES','CALF PRESS','strength')
on conflict (day_no,name) do update set
focus = excluded.focus,
type = excluded.type;

update gym_workout_templates
set
demo_url = 'https://www.muscleandstrength.com/exercises?search=' || replace(name,' ','+'),
instructions = coalesce(instructions,'Open the verified exercise guide and follow the trainer demo. Stop immediately if you feel sharp pain, dizziness, or joint discomfort.')
where demo_url is null or demo_url = '';

update gym_workouts w
set
demo_url = t.demo_url,
instructions = coalesce(w.instructions,t.instructions)
from gym_workout_templates t
where w.day_no = t.day_no
and w.name = t.name
and (w.demo_url is null or w.demo_url = '');
+

-- Curated direct-playable workout demonstrations.
-- Existing custom video URLs are preserved; only blank or generic search links are replaced.
update gym_workout_templates as t
set demo_url = v.demo_url
from (values
('BARBELL OR DUMBBELL BENCH PRESS','https://www.youtube.com/watch?v=4Y2ZdHCOXok'),
('CABLE CROSSOVERS','https://www.youtube.com/watch?v=JUDTGZh4rhg'),
('SEATED DUMBBELL PRESS','https://www.youtube.com/watch?v=rO_iEImwHyo'),
('LATERAL RAISES','https://www.youtube.com/watch?v=Y29xKcze8Ik'),
('TRICEP ROPE PUSHDOWNS','https://www.youtube.com/watch?v=vB5OHsJ3EME'),
('SKULL CRUSHERS','https://www.youtube.com/watch?v=S0fmDR60X-o'),
('PULL-UPS','https://www.youtube.com/watch?v=eGo4IYlbE5g'),
('LAT PULLDOWNS','https://www.youtube.com/watch?v=SALxEARiMkw'),
('SEATED CABLE ROWS','https://www.youtube.com/watch?v=CsROhQ1onAg'),
('BARBELL CURLS','https://www.youtube.com/watch?v=kwG2ipFRgfo'),
('HAMMER CURLS','https://www.youtube.com/watch?v=BRVDS6HVR9Q'),
('BARBELL SQUATS','https://www.youtube.com/watch?v=gcNh17Ckjgg'),
('LEG PRESS','https://www.youtube.com/watch?v=K5n2vg3oZa4'),
('LUNGES','https://www.youtube.com/watch?v=wrwwXE_x-pQ'),
('ROMANIAN DEADLIFTS','https://www.youtube.com/watch?v=5zmlnbWb-g4'),
('SEATED LEG CURLS','https://www.youtube.com/watch?v=t9sTSr-JYSs'),
('STANDING OR SEATED CALF RAISES','https://www.youtube.com/watch?v=6O5hh1rBtx8'),
('INCLINE DUMBBELL PRESS','https://www.youtube.com/watch?v=IP4oeKh1Sd4'),
('CHEST FLYS','https://www.youtube.com/watch?v=mLgYNdxj-Vw'),
('STANDING OVERHEAD PRESS','https://www.youtube.com/watch?v=KP1sYz2VICk'),
('REVERSE PEC DECK','https://www.youtube.com/watch?v=dC7jhEk-29A'),
('OVERHEAD DUMBBELL EXTENSIONS','https://www.youtube.com/watch?v=fYqswDVbJDg'),
('TRICEP DIPS','https://www.youtube.com/watch?v=6kALZikXxLc'),
('DEADLIFTS','https://www.youtube.com/watch?v=XxWcirHIwVo'),
('T-BAR ROWS','https://www.youtube.com/watch?v=TyLoy3n_a10'),
('CLOSE-GRIP PULLDOWNS','https://www.youtube.com/watch?v=8hzVLzu-RJk'),
('PREACHER CURLS','https://www.youtube.com/watch?v=R-8Sa0_qiws'),
('ALTERNATING DUMBBELL CURLS','https://www.youtube.com/watch?v=sAq_ocpRh_I'),
('FRONT SQUATS','https://www.youtube.com/watch?v=nmUof3vszxM'),
('BULGARIAN SPLIT SQUATS','https://www.youtube.com/watch?v=hiLF_pF3EJM'),
('LYING LEG CURLS','https://www.youtube.com/watch?v=vl5nUdE9mWM'),
('GLUTE BRIDGES','https://www.youtube.com/watch?v=Q_Bpj91Yiis'),
('CALF PRESS','https://www.youtube.com/watch?v=PYZY00hI43w')
) as v(name,demo_url)
where t.name = v.name
and (t.demo_url is null or t.demo_url = '' or t.demo_url like '%muscleandstrength.com/exercises?search=%');

update gym_workouts as w
set demo_url = t.demo_url,
    instructions = coalesce(w.instructions,t.instructions)
from gym_workout_templates as t
where w.day_no = t.day_no
and w.name = t.name
and t.demo_url like 'https://www.youtube.com/watch?v=%'
and (w.demo_url is null or w.demo_url = '' or w.demo_url like '%muscleandstrength.com/exercises?search=%');
