drop schema if exists amalinowska_sztosik;
create schema if not exists amalinowska_sztosik;
use amalinowska_sztosik;

create table dzwonki
(
  nr_lekcji tinyint not null
    primary key,
  poczatek  time    not null,
  koniec    time    not null
);

create table nauczyciele
(
  pesel          char(11)    not null
    primary key,
  imie           varchar(30) not null,
  nazwisko       varchar(30) not null,
  data_urodzenia date        not null,
  adres          varchar(50) not null,
  nr_kontaktowy  int         not null
);

create table przedmioty
(
  id_przedmiotu int auto_increment
    primary key,
  nazwa         varchar(20) not null
);

create table kursy
(
  id_kursu       int auto_increment
    primary key,
  id_nauczyciela char(11) not null,
  id_przedmiotu  int      not null,
  constraint kursy_ibfk_1
    foreign key (id_nauczyciela) references nauczyciele (pesel),
  constraint kursy_ibfk_2
    foreign key (id_przedmiotu) references przedmioty (id_przedmiotu)
);

create index id_nauczyciela
  on kursy (id_nauczyciela);

create index id_przedmiotu
  on kursy (id_przedmiotu);

create table sale
(
  nr_sali   int                          not null
    primary key,
  pojemnosc int                          not null,
  typ       varchar(20) default 'ogólna' not null
);

create table klasy
(
  id_klasy   char(4)  not null
    primary key,
  liczebnosc tinyint  not null,
  wychowawca char(11) not null,
  sala       int      null,
  constraint klasy_ibfk_1
    foreign key (wychowawca) references nauczyciele (pesel),
  constraint klasy_sale_lekcyjne_nr_sali_fk
    foreign key (sala) references sale (nr_sali)
);

create index wychowawca
  on klasy (wychowawca);

create table uczniowie
(
  pesel           char(11)    not null
    primary key,
  imie            varchar(30) not null,
  nazwisko        varchar(30) not null,
  data_urodzenia  date        not null,
  adres           varchar(50) not null,
  tel_do_rodzica1 int         not null,
  tel_do_rodzica2 int         null
);

create table klasa_uczniowie
(
  id_klasy  char(4)  not null,
  id_ucznia char(11) not null,
  primary key (id_klasy, id_ucznia),
  constraint klasa_uczniowie_ibfk_1
    foreign key (id_klasy) references klasy (id_klasy),
  constraint klasa_uczniowie_ibfk_2
    foreign key (id_ucznia) references uczniowie (pesel)
);

create index id_ucznia
  on klasa_uczniowie (id_ucznia);

create table oceny
(
  id_oceny  int auto_increment
    primary key,
  id_ucznia char(11)                                                                       not null,
  id_kursu  int                                                                            not null,
  data      date                                                                           not null,
  waga      tinyint                                                    default 1           not null,
  typ       enum ('cząstkowa', 'prop_sem', 'sem', 'prop_rocz', 'rocz') default 'cząstkowa' not null,
  wartosc   enum ('+', '-', '1', '2-', '2', '2+', '3-', '3', '3+', '4-', '4', '4+', '5-', '5', '5+', '6') not null,
  constraint oceny_ibfk_1
    foreign key (id_ucznia) references uczniowie (pesel),
  constraint oceny_ibfk_2
    foreign key (id_kursu) references kursy (id_kursu)
);

create index id_kursu
  on oceny (id_kursu);

create index oceny_id_ucznia_id_przedmiotu_index
  on oceny (id_ucznia, id_kursu);

create index uczniowie_imie_nazwisko_index
  on uczniowie (imie, nazwisko);

create table zajecia
(
  id_zajec       int auto_increment
    primary key,
  id_kursu       int                                   not null,
  id_klasy       char(4)                               not null,
  id_sali        int                                   not null,
  nr_lekcji      tinyint                               not null,
  dzien_tygodnia enum ('pon', 'wt', 'śr', 'czw', 'pt') not null,
  semestr        char(4)                               not null,
  constraint zajecia_ibfk_1
    foreign key (id_kursu) references kursy (id_kursu),
  constraint zajecia_ibfk_2
    foreign key (id_klasy) references klasy (id_klasy),
  constraint zajecia_ibfk_3
    foreign key (id_sali) references sale (nr_sali),
  constraint zajecia_ibfk_4
    foreign key (nr_lekcji) references dzwonki (nr_lekcji)
);

create index id_sali
  on zajecia (id_sali);

create index nr_lekcji
  on zajecia (nr_lekcji);

create index zajecia_id_klasy_id_przedmiotu_index
  on zajecia (id_klasy, id_kursu);

create index zajecia_id_klasy_index
  on zajecia (id_klasy);

create index zajecia_id_nauczyciela_index
  on zajecia (id_kursu);

