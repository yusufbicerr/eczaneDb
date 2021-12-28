--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1
-- Dumped by pg_dump version 14.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: ilacEkle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."ilacEkle"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW."ilacadi" = UPPER(NEW."ilacadi"); -- büyük harfe dönüştürdükten sonra ekle
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."ilacEkle"() OWNER TO postgres;

--
-- Name: ilacFiyatDegistiginde(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."ilacFiyatDegistiginde"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW."birimfiyati" <> OLD."birimfiyati" THEN
        INSERT INTO "UrunDegisikligiIzle"("urunNo", "eskiBirimFiyat", "yeniBirimFiyat", "degisiklikTarihi")
        VALUES(OLD."ilacid", OLD."birimfiyati", NEW."birimfiyati", CURRENT_TIMESTAMP::TIMESTAMP);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public."ilacFiyatDegistiginde"() OWNER TO postgres;

--
-- Name: ilacsayi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ilacsayi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF((SELECT COUNT(*) FROM "ilac" WHERE "ilacid" = NEW."ilacid")>25)
	THEN 
		RAISE EXCEPTION '25 ten fazla ilac eklenemez';
	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.ilacsayi() OWNER TO postgres;

--
-- Name: ilacsayisi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ilacsayisi() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
DECLARE 
	total INT DEFAULT 0;	
BEGIN
    SELECT COUNT(ilacid) INTO total
	FROM ilac;
	RETURN total;
END;
$$;


ALTER FUNCTION public.ilacsayisi() OWNER TO postgres;

--
-- Name: musteriEkle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."musteriEkle"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW."musterisoyadi" = UPPER(NEW."musterisoyadi"); 
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."musteriEkle"() OWNER TO postgres;

--
-- Name: musteriara(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.musteriara(musterino integer) RETURNS TABLE(id integer, adi character varying, soyadi character varying, ilce integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT "musteriid", "musteriadi", "musterisoyadi","ilceno" FROM musteri
                 WHERE "musteriid" = musteriNo;
END;
$$;


ALTER FUNCTION public.musteriara(musterino integer) OWNER TO postgres;

--
-- Name: tedarikcistok(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.tedarikcistok(tedarikcino integer) RETURNS TABLE(id integer, stok integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT "tedarikciid", "stokmiktari" FROM ilac
                 WHERE "tedarikciid" = tedarikciNo;
END;
$$;


ALTER FUNCTION public.tedarikcistok(tedarikcino integer) OWNER TO postgres;

--
-- Name: toplamsiparistutar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.toplamsiparistutar() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
DECLARE 
	total INT DEFAULT 0;	
BEGIN
    SELECT SUM(toplamtutar) INTO total
	FROM siparis;
	RETURN total;
END;
$$;


ALTER FUNCTION public.toplamsiparistutar() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: UrunDegisikligiIzle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."UrunDegisikligiIzle" (
    "kayitNo" integer NOT NULL,
    "urunNo" smallint NOT NULL,
    "eskiBirimFiyat" real NOT NULL,
    "yeniBirimFiyat" real NOT NULL,
    "degisiklikTarihi" timestamp without time zone NOT NULL
);


ALTER TABLE public."UrunDegisikligiIzle" OWNER TO postgres;

--
-- Name: UrunDegisikligiIzle_kayitNo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."UrunDegisikligiIzle_kayitNo_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."UrunDegisikligiIzle_kayitNo_seq" OWNER TO postgres;

--
-- Name: UrunDegisikligiIzle_kayitNo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."UrunDegisikligiIzle_kayitNo_seq" OWNED BY public."UrunDegisikligiIzle"."kayitNo";


--
-- Name: eczane; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.eczane (
    eczaneid integer NOT NULL,
    sehirno integer NOT NULL,
    eczaneadi character varying(30) NOT NULL
);


ALTER TABLE public.eczane OWNER TO postgres;

--
-- Name: ilac; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ilac (
    ilacid integer NOT NULL,
    turid integer NOT NULL,
    receteid integer NOT NULL,
    tedarikciid integer NOT NULL,
    ilacadi character varying(30) NOT NULL,
    stokmiktari integer NOT NULL,
    birimfiyati numeric NOT NULL
);


ALTER TABLE public.ilac OWNER TO postgres;

--
-- Name: ilacsiparis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ilacsiparis (
    siparis_id integer NOT NULL,
    ilac_id integer NOT NULL,
    adet integer NOT NULL,
    birimfiyati numeric NOT NULL
);


ALTER TABLE public.ilacsiparis OWNER TO postgres;

--
-- Name: ilactur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ilactur (
    turid integer NOT NULL,
    turadi character varying(30) NOT NULL
);


ALTER TABLE public.ilactur OWNER TO postgres;

--
-- Name: ilce; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ilce (
    ilceno integer NOT NULL,
    ilceadi character varying(30) NOT NULL,
    sehirno integer NOT NULL
);


ALTER TABLE public.ilce OWNER TO postgres;

--
-- Name: iletisimBilgileri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."iletisimBilgileri" (
    iletisimid integer NOT NULL,
    musteriid integer NOT NULL,
    telefon character varying(30) NOT NULL,
    fax character varying(30)
);


ALTER TABLE public."iletisimBilgileri" OWNER TO postgres;

--
-- Name: kargo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kargo (
    kargoid integer NOT NULL,
    kargoadi character varying(30) NOT NULL
);


ALTER TABLE public.kargo OWNER TO postgres;

--
-- Name: musteri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musteri (
    musteriid integer NOT NULL,
    ilceno integer NOT NULL,
    musteriadi character varying(30) NOT NULL,
    musterisoyadi character varying(30) NOT NULL
);


ALTER TABLE public.musteri OWNER TO postgres;

--
-- Name: odemeyontemi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.odemeyontemi (
    odemeid integer NOT NULL,
    odemeadi character varying(30) NOT NULL
);


ALTER TABLE public.odemeyontemi OWNER TO postgres;

--
-- Name: personel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personel (
    personelid integer NOT NULL,
    eczaneid integer NOT NULL,
    personeladi character varying(30) NOT NULL,
    personelsoyadi character varying(30) NOT NULL
);


ALTER TABLE public.personel OWNER TO postgres;

--
-- Name: recete; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recete (
    receteid integer NOT NULL,
    recetetur character varying(30) NOT NULL
);


ALTER TABLE public.recete OWNER TO postgres;

--
-- Name: sehir; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sehir (
    sehirno integer NOT NULL,
    sehiradi character varying(30) NOT NULL
);


ALTER TABLE public.sehir OWNER TO postgres;

--
-- Name: siparis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.siparis (
    siparisid integer NOT NULL,
    musteriid integer NOT NULL,
    personelid integer NOT NULL,
    kargoid integer NOT NULL,
    odemeid integer NOT NULL,
    toplamtutar numeric NOT NULL
);


ALTER TABLE public.siparis OWNER TO postgres;

--
-- Name: tedarikci; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tedarikci (
    tedarikciid integer NOT NULL,
    ulkeid integer NOT NULL,
    sirketadi character varying(30) NOT NULL,
    telefon character varying(30)
);


ALTER TABLE public.tedarikci OWNER TO postgres;

--
-- Name: ulke; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ulke (
    ulkeid integer NOT NULL,
    ulkeadi character varying(30) NOT NULL
);


ALTER TABLE public.ulke OWNER TO postgres;

--
-- Name: UrunDegisikligiIzle kayitNo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."UrunDegisikligiIzle" ALTER COLUMN "kayitNo" SET DEFAULT nextval('public."UrunDegisikligiIzle_kayitNo_seq"'::regclass);


--
-- Data for Name: UrunDegisikligiIzle; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."UrunDegisikligiIzle" VALUES
	(1, 7, 24, 14, '2021-12-18 18:56:55.980369'),
	(2, 7, 24, 14, '2021-12-18 18:56:55.980369');


--
-- Data for Name: eczane; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.eczane VALUES
	(1, 1, 'Gülücük Eczanesi'),
	(2, 5, 'Mutlu Eczanesi'),
	(3, 3, 'Başak Eczanesi'),
	(4, 3, 'Kılıç Eczanesi');


--
-- Data for Name: ilac; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ilac VALUES
	(1, 4, 1, 2, 'Parol', 150, 10.00),
	(2, 4, 1, 2, 'Aspirin', 100, 15.00),
	(3, 2, 1, 2, 'Calpol', 200, 20.00),
	(4, 5, 3, 4, 'Göz Damlası', 50, 5.00),
	(5, 9, 1, 1, 'Burun Spreyi', 25, 12.50),
	(6, 6, 1, 5, 'Nemlendirici', 120, 30.00),
	(7, 5, 4, 2, 'ASDSAF', 20, 14);


--
-- Data for Name: ilacsiparis; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ilacsiparis VALUES
	(1, 1, 5, 10),
	(2, 1, 10, 10),
	(1, 2, 7, 15),
	(4, 1, 4, 10),
	(3, 1, 2, 10);


--
-- Data for Name: ilactur; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ilactur VALUES
	(1, 'Kapsül'),
	(2, 'Şurup'),
	(3, 'Krem'),
	(4, 'Tablet'),
	(5, 'Damla'),
	(6, 'Losyon'),
	(7, 'Toz'),
	(8, 'Ampul'),
	(9, 'Sprey'),
	(10, 'Merhem');


--
-- Data for Name: ilce; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ilce VALUES
	(1, 'Beşiktaş', 3),
	(2, 'Kartal', 3),
	(3, 'Üsküdar', 3),
	(4, 'Ümraniye', 3),
	(5, 'Beykoz', 3),
	(6, 'Sultanbeyli', 3),
	(7, 'Akyurt', 1),
	(8, 'Alanya', 2),
	(9, 'Bornova', 4),
	(10, 'Adapazarı', 5),
	(11, 'Gebze', 6);


--
-- Data for Name: iletisimBilgileri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."iletisimBilgileri" VALUES
	(1, 1, '05322343432', ''),
	(2, 2, '05382844437', ''),
	(3, 4, '05399849439', '1234');


--
-- Data for Name: kargo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.kargo VALUES
	(1, 'Aras'),
	(2, 'PTT');


--
-- Data for Name: musteri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.musteri VALUES
	(1, 3, 'Namık', 'Kemal'),
	(2, 1, 'Murat', 'Telli'),
	(3, 4, 'Dilara', 'Karadağ'),
	(4, 2, 'Şafak', 'Sezer'),
	(5, 3, 'Ayşe', 'Gül'),
	(6, 6, 'Leyla', 'Kuzu'),
	(7, 1, 'Kemal', 'Aydın'),
	(8, 1, 'Ceylan', 'Murat'),
	(20, 5, 'Ali', 'Karakurt'),
	(10, 1, 'Cansu', 'Kozlu'),
	(11, 1, 'adfdadf', 'fafa'),
	(12, 6, 'adfadaagdag', 'afadfad'),
	(13, 8, 'asfagada', 'adfafa'),
	(25, 1, 'agadfagadafsa', 'fadfa'),
	(30, 1, 'aeqetqejq', 'adgadg'),
	(50, 9, 'dghadlgkad', 'dkghaldgjad'),
	(35, 1, 'dgkadgla', 'DLKGALDGA'),
	(60, 6, 'adgdagdag', 'ADGADGDAG');


--
-- Data for Name: odemeyontemi; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.odemeyontemi VALUES
	(1, 'Peşin'),
	(2, 'Taksit'),
	(3, 'Nakit');


--
-- Data for Name: personel; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.personel VALUES
	(1, 4, 'Yusuf', 'Biçer'),
	(2, 3, 'Ali', 'Kurt'),
	(3, 1, 'Mehmet', 'Turan'),
	(4, 2, 'Kenan', 'Dağ');


--
-- Data for Name: recete; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recete VALUES
	(1, 'Beyaz Reçete'),
	(2, 'Kırmızı Reçete'),
	(3, 'Yeşil Reçete'),
	(4, 'Turuncu Reçete'),
	(5, 'Mor Reçete');


--
-- Data for Name: sehir; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sehir VALUES
	(1, 'Ankara'),
	(2, 'Antalya'),
	(3, 'İstanbul'),
	(4, 'İzmir'),
	(5, 'Sakarya'),
	(6, 'Kocaeli');


--
-- Data for Name: siparis; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.siparis VALUES
	(1, 1, 1, 1, 1, 50.00),
	(2, 1, 1, 1, 2, 75),
	(3, 2, 3, 1, 2, 25.50),
	(4, 3, 2, 2, 1, 60),
	(9, 13, 1, 1, 1, 20),
	(8, 25, 3, 1, 1, 25),
	(30, 30, 2, 2, 3, 50),
	(15, 50, 2, 2, 2, 100),
	(35, 35, 2, 2, 3, 130),
	(10, 60, 2, 2, 2, 200);


--
-- Data for Name: tedarikci; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tedarikci VALUES
	(1, 1, 'Johnson & Johnson', '9514351332'),
	(2, 2, 'Pfizer', '5362312452'),
	(3, 11, 'Novartis', '8374151232'),
	(4, 6, 'Sinopharm Group', '2314532123'),
	(5, 4, 'Sanofi', '4315215678');


--
-- Data for Name: ulke; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ulke VALUES
	(1, 'ABD'),
	(2, 'Turkiye'),
	(3, 'Almanya'),
	(4, 'Fransa'),
	(5, 'Rusya'),
	(6, 'Çin'),
	(7, 'İngiltere'),
	(8, 'Hindistan'),
	(9, 'Mısır'),
	(10, 'Avusturya'),
	(11, 'İsviçre');


--
-- Name: UrunDegisikligiIzle_kayitNo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."UrunDegisikligiIzle_kayitNo_seq"', 2, true);


--
-- Name: eczane Eczane_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eczane
    ADD CONSTRAINT "Eczane_pkey" PRIMARY KEY (eczaneid);


--
-- Name: odemeyontemi Fatura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.odemeyontemi
    ADD CONSTRAINT "Fatura_pkey" PRIMARY KEY (odemeid);


--
-- Name: ilacsiparis IlacSiparis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilacsiparis
    ADD CONSTRAINT "IlacSiparis_pkey" PRIMARY KEY (siparis_id, ilac_id);


--
-- Name: ilactur IlacTur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilactur
    ADD CONSTRAINT "IlacTur_pkey" PRIMARY KEY (turid);


--
-- Name: ilac Ilac_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilac
    ADD CONSTRAINT "Ilac_pkey" PRIMARY KEY (ilacid);


--
-- Name: ilce Ilce_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilce
    ADD CONSTRAINT "Ilce_pkey" PRIMARY KEY (ilceno);


--
-- Name: iletisimBilgileri IletisimBilgileri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."iletisimBilgileri"
    ADD CONSTRAINT "IletisimBilgileri_pkey" PRIMARY KEY (iletisimid);


--
-- Name: kargo Kargo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kargo
    ADD CONSTRAINT "Kargo_pkey" PRIMARY KEY (kargoid);


--
-- Name: musteri Musteri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri
    ADD CONSTRAINT "Musteri_pkey" PRIMARY KEY (musteriid);


--
-- Name: UrunDegisikligiIzle PK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."UrunDegisikligiIzle"
    ADD CONSTRAINT "PK" PRIMARY KEY ("kayitNo");


--
-- Name: personel Personel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT "Personel_pkey" PRIMARY KEY (personelid);


--
-- Name: recete Recete_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recete
    ADD CONSTRAINT "Recete_pkey" PRIMARY KEY (receteid);


--
-- Name: sehir Sehir_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sehir
    ADD CONSTRAINT "Sehir_pkey" PRIMARY KEY (sehirno);


--
-- Name: siparis Siparis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT "Siparis_pkey" PRIMARY KEY (siparisid);


--
-- Name: tedarikci Tedarikci_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci
    ADD CONSTRAINT "Tedarikci_pkey" PRIMARY KEY (tedarikciid);


--
-- Name: ulke Ulke_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ulke
    ADD CONSTRAINT "Ulke_pkey" PRIMARY KEY (ulkeid);


--
-- Name: fki_eczaneSehir_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_eczaneSehir_foreign" ON public.eczane USING btree (sehirno);


--
-- Name: fki_ilacTedarikci_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_ilacTedarikci_foreign" ON public.ilac USING btree (tedarikciid);


--
-- Name: fki_ilac_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_ilac_foreign ON public.ilac USING btree (turid);


--
-- Name: fki_ilac_id_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_ilac_id_foreign ON public.ilacsiparis USING btree (ilac_id);


--
-- Name: fki_ilceSehir_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_ilceSehir_foreign" ON public.ilce USING btree (sehirno);


--
-- Name: fki_iletisimMusteri_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_iletisimMusteri_foreign" ON public."iletisimBilgileri" USING btree (musteriid);


--
-- Name: fki_m; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_m ON public.siparis USING btree (musteriid);


--
-- Name: fki_musteriIlce; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_musteriIlce" ON public.musteri USING btree (ilceno);


--
-- Name: fki_personelEczane_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_personelEczane_foreign" ON public.personel USING btree (eczaneid);


--
-- Name: fki_siparisFatura_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_siparisFatura_foreign" ON public.siparis USING btree (odemeid);


--
-- Name: fki_siparisKargo_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_siparisKargo_foreign" ON public.siparis USING btree (kargoid);


--
-- Name: fki_siparisPersonel_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_siparisPersonel_foreign" ON public.siparis USING btree (personelid);


--
-- Name: fki_siparis_id_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_siparis_id_foreign ON public.ilacsiparis USING btree (siparis_id);


--
-- Name: fki_tedarikciUlke_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_tedarikciUlke_foreign" ON public.tedarikci USING btree (ulkeid);


--
-- Name: fki_İ; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_İ" ON public.ilac USING btree (receteid);


--
-- Name: ilac ilacFiyatDegistiginde; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ilacFiyatDegistiginde" BEFORE UPDATE ON public.ilac FOR EACH ROW EXECUTE FUNCTION public."ilacFiyatDegistiginde"();


--
-- Name: ilac ilacKontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ilacKontrol" BEFORE INSERT OR UPDATE ON public.ilac FOR EACH ROW EXECUTE FUNCTION public."ilacEkle"();


--
-- Name: ilac ilacsayisimax; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ilacsayisimax BEFORE UPDATE ON public.ilac FOR EACH ROW EXECUTE FUNCTION public.ilacsayi();


--
-- Name: musteri musteriKontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "musteriKontrol" BEFORE INSERT OR UPDATE ON public.musteri FOR EACH ROW EXECUTE FUNCTION public."musteriEkle"();


--
-- Name: ilac urunBirimFiyatDegistiginde; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "urunBirimFiyatDegistiginde" BEFORE UPDATE ON public.ilac FOR EACH ROW EXECUTE FUNCTION public."ilacFiyatDegistiginde"();


--
-- Name: eczane eczaneSehir_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eczane
    ADD CONSTRAINT "eczaneSehir_foreign" FOREIGN KEY (sehirno) REFERENCES public.sehir(sehirno) NOT VALID;


--
-- Name: ilac ilacRecete_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilac
    ADD CONSTRAINT "ilacRecete_foreign" FOREIGN KEY (receteid) REFERENCES public.recete(receteid) NOT VALID;


--
-- Name: ilac ilacTedarikci_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilac
    ADD CONSTRAINT "ilacTedarikci_foreign" FOREIGN KEY (tedarikciid) REFERENCES public.tedarikci(tedarikciid) NOT VALID;


--
-- Name: ilac ilacTur_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilac
    ADD CONSTRAINT "ilacTur_foreign" FOREIGN KEY (turid) REFERENCES public.ilactur(turid) NOT VALID;


--
-- Name: ilacsiparis ilac_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilacsiparis
    ADD CONSTRAINT ilac_id_foreign FOREIGN KEY (ilac_id) REFERENCES public.ilac(ilacid) NOT VALID;


--
-- Name: ilce ilceSehir_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilce
    ADD CONSTRAINT "ilceSehir_foreign" FOREIGN KEY (sehirno) REFERENCES public.sehir(sehirno) NOT VALID;


--
-- Name: iletisimBilgileri iletisimMusteri_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."iletisimBilgileri"
    ADD CONSTRAINT "iletisimMusteri_foreign" FOREIGN KEY (musteriid) REFERENCES public.musteri(musteriid) NOT VALID;


--
-- Name: musteri musteriIlce; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri
    ADD CONSTRAINT "musteriIlce" FOREIGN KEY (ilceno) REFERENCES public.ilce(ilceno) NOT VALID;


--
-- Name: personel personelEczane_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT "personelEczane_foreign" FOREIGN KEY (eczaneid) REFERENCES public.eczane(eczaneid) NOT VALID;


--
-- Name: siparis siparisFatura_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT "siparisFatura_foreign" FOREIGN KEY (odemeid) REFERENCES public.odemeyontemi(odemeid) NOT VALID;


--
-- Name: siparis siparisKargo_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT "siparisKargo_foreign" FOREIGN KEY (kargoid) REFERENCES public.kargo(kargoid) NOT VALID;


--
-- Name: siparis siparisMusteri_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT "siparisMusteri_foreign" FOREIGN KEY (musteriid) REFERENCES public.musteri(musteriid) NOT VALID;


--
-- Name: siparis siparisPersonel_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT "siparisPersonel_foreign" FOREIGN KEY (personelid) REFERENCES public.personel(personelid) NOT VALID;


--
-- Name: ilacsiparis siparis_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilacsiparis
    ADD CONSTRAINT siparis_id_foreign FOREIGN KEY (siparis_id) REFERENCES public.siparis(siparisid) NOT VALID;


--
-- Name: tedarikci tedarikciUlke_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci
    ADD CONSTRAINT "tedarikciUlke_foreign" FOREIGN KEY (ulkeid) REFERENCES public.ulke(ulkeid) NOT VALID;


--
-- PostgreSQL database dump complete
--

