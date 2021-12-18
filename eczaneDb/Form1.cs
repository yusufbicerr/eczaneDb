using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace eczaneDb
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
        NpgsqlConnection baglanti = new NpgsqlConnection("server=localHost; port=5432; Database=eczaneDb; user ID=postgres; password=YBicer9747.");

        public int yazdir()
        {
            string sorgu = "select * from ilac";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];
            return 0;
        }
        private void ekle_button_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            NpgsqlCommand ekle1 = new NpgsqlCommand("insert into ilac (ilacid,ilacadi,turid,receteid,tedarikciid,stokmiktari,birimfiyati) values (@p1,@p2,@p3,@p4,@p5,@p6,@p7)", baglanti);

            ekle1.Parameters.AddWithValue("@p1", int.Parse(ekletbox1.Text));
            ekle1.Parameters.AddWithValue("@p2", ekletbox2.Text);
            ekle1.Parameters.AddWithValue("@p3", int.Parse(comboBox1.SelectedValue.ToString()));
            ekle1.Parameters.AddWithValue("@p4", int.Parse(comboBox2.SelectedValue.ToString()));
            ekle1.Parameters.AddWithValue("@p5", int.Parse(comboBox3.SelectedValue.ToString()));
            ekle1.Parameters.AddWithValue("@p6", int.Parse(ekletbox6.Text));
            ekle1.Parameters.AddWithValue("@p7", int.Parse(ekletbox7.Text));
            ekle1.ExecuteNonQuery();
            baglanti.Close();           
            MessageBox.Show("ilac ekleme islemi basarili");
            yazdir();
        }

        private void silme_button_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            NpgsqlCommand sil = new NpgsqlCommand("Delete from ilac where ilacid=@p1", baglanti);
            sil.Parameters.AddWithValue("@p1", int.Parse(ekletbox1.Text));
            sil.ExecuteNonQuery();
            baglanti.Close();
            MessageBox.Show("Urun silme islemi basarili");
            yazdir();
        }

        private void guncelleme_button_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            NpgsqlCommand guncelle = new NpgsqlCommand("update ilac set ilacadi=@p1,turid=@p2,receteid=@p3,tedarikciid=@p4,stokmiktari=@p5,birimfiyati=@p6 where ilacid=@p7", baglanti);
            guncelle.Parameters.AddWithValue("@p1", ekletbox2.Text);
            guncelle.Parameters.AddWithValue("@p2", int.Parse(comboBox1.SelectedValue.ToString()));
            guncelle.Parameters.AddWithValue("@p3", int.Parse(comboBox2.SelectedValue.ToString()));
            guncelle.Parameters.AddWithValue("@p4", int.Parse(comboBox3.SelectedValue.ToString()));
            guncelle.Parameters.AddWithValue("@p5", int.Parse(ekletbox6.Text));
            guncelle.Parameters.AddWithValue("@p6", int.Parse(ekletbox7.Text));
            guncelle.Parameters.AddWithValue("@p7", int.Parse(ekletbox1.Text));
            guncelle.ExecuteNonQuery();
            MessageBox.Show("Urun basariyla guncellendi");
            yazdir();
            baglanti.Close();
        }

        private void ilac_al_button_Click(object sender, EventArgs e)
        {
            satis satis = new satis();
            satis.ShowDialog();
        }

        private void arama_button_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            DataSet ds = new DataSet();
            NpgsqlDataAdapter da = new NpgsqlDataAdapter("select * from ilac where ilacadi like'%" + ekletbox2.Text + "%'", baglanti);
            da.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];
            baglanti.Close();
        }   

        private void button1_Click(object sender, EventArgs e)
        {
            string sorgu = "select * from ilac";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            baglanti.Open();
            NpgsqlDataAdapter da1 = new NpgsqlDataAdapter("select * from ilactur", baglanti);
            NpgsqlDataAdapter da2 = new NpgsqlDataAdapter("select * from recete", baglanti);
            NpgsqlDataAdapter da3 = new NpgsqlDataAdapter("select * from tedarikci", baglanti);
            DataTable dt1 = new DataTable();
            DataTable dt2 = new DataTable();
            DataTable dt3 = new DataTable();
            da1.Fill(dt1);
            da2.Fill(dt2);
            da3.Fill(dt3);
            comboBox1.DisplayMember = "turadi";
            comboBox1.ValueMember = "turid";
            comboBox2.DisplayMember = "recetetur";
            comboBox2.ValueMember = "receteid";
            comboBox3.DisplayMember = "sirketadi";
            comboBox3.ValueMember = "tedarikciid";
            comboBox1.DataSource = dt1;
            comboBox2.DataSource = dt2;
            comboBox3.DataSource = dt3;
            baglanti.Close();
        }
    }
}
