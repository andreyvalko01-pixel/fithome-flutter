import '../models.dart';

/// Програми тренувань. Зберігаються в коді, щоб працювали без інтернету;
/// за потреби їх легко перенести в Firestore.
const programs = <Workout>[
  Workout(
    id: 'morning',
    title: 'Ранкова зарядка',
    level: 'Початковий',
    focus: 'Усе тіло',
    exercises: [
      Exercise(
        name: 'Обертання плечима',
        hint: 'Повільно, по 10 разів вперед і назад',
        seconds: 40,
        rest: 10,
      ),
      Exercise(
        name: 'Нахили в сторони',
        hint: 'Руки на поясі, спина рівна',
        seconds: 40,
        rest: 10,
      ),
      Exercise(
        name: 'Присідання',
        hint: 'Коліна не виходять за носки',
        reps: 15,
      ),
      Exercise(
        name: 'Випади на місці',
        hint: 'Почергово кожною ногою',
        reps: 12,
      ),
      Exercise(name: 'Планка', hint: 'Тіло — одна пряма лінія', seconds: 30),
    ],
  ),
  Workout(
    id: 'fullbody',
    title: 'Full body без інвентарю',
    level: 'Середній',
    focus: 'Сила і витривалість',
    rounds: 3,
    exercises: [
      Exercise(name: 'Віджимання', hint: 'Можна з колін, якщо важко', reps: 12),
      Exercise(
        name: 'Присідання з вистрибуванням',
        hint: 'М’яко приземляйтесь на носки',
        reps: 15,
      ),
      Exercise(name: 'Скелелаз', hint: 'Таз не піднімайте вгору', seconds: 30),
      Exercise(
        name: 'Ягодичний міст',
        hint: 'Затримка 1 секунда вгорі',
        reps: 15,
      ),
      Exercise(
        name: 'Бокова планка',
        hint: 'По 15 секунд на кожен бік',
        seconds: 30,
        rest: 30,
      ),
    ],
  ),
  Workout(
    id: 'abs',
    title: 'Прес за 15 хвилин',
    level: 'Середній',
    focus: 'Кор',
    rounds: 2,
    exercises: [
      Exercise(
        name: 'Скручування',
        hint: 'Поперек притиснутий до підлоги',
        reps: 20,
      ),
      Exercise(
        name: 'Велосипед',
        hint: 'Лікоть до протилежного коліна',
        seconds: 40,
      ),
      Exercise(
        name: 'Підйом ніг лежачи',
        hint: 'Повільно опускайте, не кидайте',
        reps: 12,
      ),
      Exercise(
        name: 'Планка',
        hint: 'Не провисайте в попереку',
        seconds: 45,
        rest: 30,
      ),
    ],
  ),
  Workout(
    id: 'stretch',
    title: 'Розтяжка після роботи',
    level: 'Початковий',
    focus: 'Гнучкість',
    exercises: [
      Exercise(
        name: 'Кішка-корова',
        hint: 'Дихайте разом з рухом',
        seconds: 45,
        rest: 10,
      ),
      Exercise(
        name: 'Нахил до ніг сидячи',
        hint: 'Тягніться грудьми, не головою',
        seconds: 45,
        rest: 10,
      ),
      Exercise(
        name: 'Поза дитини',
        hint: 'Розслабте плечі',
        seconds: 60,
        rest: 10,
      ),
      Exercise(
        name: 'Розтяжка стегна у випаді',
        hint: 'По 30 секунд на кожну ногу',
        seconds: 60,
        rest: 10,
      ),
    ],
  ),
];

Workout workoutById(String id) => programs.firstWhere((w) => w.id == id);
