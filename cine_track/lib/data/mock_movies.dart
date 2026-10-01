import '../models/movie.dart';

const List<Movie> mockMovies = [
  Movie(
    id: 1,
    title: 'Inception',
    overview: 'Кобб — вор, который проникает в сны людей, чтобы похитить ценные секреты.',
    voteAverage: 8.8,
    releaseDate: '2010-07-16',
    genreIds: [28, 878, 12],
  ),
  Movie(
    id: 2,
    title: 'Interstellar',
    overview: 'Когда засуха приводит человечество к продовольственному кризису, группа исследователей улетает сквозь червоточину.',
    voteAverage: 8.6,
    releaseDate: '2014-11-05',
    genreIds: [18, 878, 12],
  ),
  Movie(
    id: 3,
    title: 'The Dark Knight',
    overview:
        'Бэтмен противостоит Джокеру — анархисту, сеющему хаос в Готэм-Сити.',
    voteAverage: 9.0,
    releaseDate: '2008-07-18',
    genreIds: [28, 80, 18],
  ),
  Movie(
    id: 4,
    title: 'Parasite',
    overview: null, // описание намеренно отсутствует
    voteAverage: null, // рейтинг ещё не выставлен
    releaseDate: '2019-05-30',
    genreIds: [35, 18, 53],
  ),
  Movie(
    id: 5,
    title: 'Dune',
    overview: 'Юный Пол Атрейдес отправляется на опасную планету Арракис.',
    voteAverage: 8.0,
    releaseDate: '2021-10-22',
    genreIds: [878, 12],
  ),
];
