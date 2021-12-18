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
    public partial class satis : Form
    {
        public satis()
        {
            InitializeComponent();
        }
        NpgsqlConnection baglanti = new NpgsqlConnection("server=localHost; port=5432; Database=eczaneDb; user ID=postgres; password=YBicer9747.");

        public int yazdir()
        {
            string sorgu = "select * from siparis";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];
            return 0;
        }
        public int yazdir2()
        {
            string sorgu = "select * from musteri";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];
            return 0;
        }
        private void satis_Load(object sender, EventArgs e)
        {
            baglanti.Open();
            NpgsqlDataAdapter da1 = new NpgsqlDataAdapter("select * from kargo", baglanti);
            NpgsqlDataAdapter da2 = new NpgsqlDataAdapter("select * from odemeyontemi", baglanti);
            NpgsqlDataAdapter da3 = new NpgsqlDataAdapter("select * from ilce", baglanti);
            DataTable dt1 = new DataTable();
            DataTable dt2 = new DataTable();
            DataTable dt3 = new DataTable();
            da1.Fill(dt1);
            da2.Fill(dt2);
            da3.Fill(dt3);
            comboBox1.DisplayMember = "kargoadi";
            comboBox1.ValueMember = "kargoid";
            comboBox2.DisplayMember = "odemeadi";
            comboBox2.ValueMember = "odemeid";
            comboBox3.DisplayMember = "ilceadi";
            comboBox3.ValueMember = "ilceno";
            comboBox1.DataSource = dt1;
            comboBox2.DataSource = dt2;
            comboBox3.DataSource = dt3;
            baglanti.Close();
        }

        private void button1_Click(object sender, EventArgs e)//musteri kaydet
        {
            textBox1.Visible = true;
            textBox4.Visible = true;
            textBox6.Visible = true;
            comboBox1.Visible = true;
            comboBox2.Visible = true;
            label1.Visible = true;
            label2.Visible = true;
            label3.Visible = true;
            label4.Visible = true;
            label5.Visible = true;
            label6.Visible = true;
            siparisekle.Visible = true;

            baglanti.Open();
            NpgsqlCommand eklemusteri = new NpgsqlCommand("insert into musteri (musteriid,ilceno,musteriadi,musterisoyadi) values (@p1,@p2,@p3,@p4)", baglanti);

            eklemusteri.Parameters.AddWithValue("@p1", int.Parse(textBox7.Text));
            eklemusteri.Parameters.AddWithValue("@p2", int.Parse(comboBox3.SelectedValue.ToString()));
            eklemusteri.Parameters.AddWithValue("@p3", textBox8.Text);
            eklemusteri.Parameters.AddWithValue("@p4", textBox3.Text);
            eklemusteri.ExecuteNonQuery();
            baglanti.Close();
            MessageBox.Show("Musteri ekleme islemi basarili.Simdi siparis ekleyebilirsiniz");
            label10.Visible = false;
            label5.Visible = false;
            label7.Visible = false;
            label8.Visible = false;
            label9.Visible = false;
            textBox3.Visible = false;
            textBox7.Visible = false;
            textBox8.Visible = false;
            comboBox3.Visible = false;
            button1.Visible = false;
            button2.Visible = false;
            label11.Visible = true;
            siparislistele.Location = new Point(799, 364);
            yazdir2();

        }

        private void siparislistele_Click(object sender, EventArgs e) //siparisleri yazdır
        {
            yazdir();
        }

        private void button2_Click(object sender, EventArgs e) //musterileri yazdır
        {
            yazdir2();
        }

        private void siparisekle_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            NpgsqlCommand eklesiparis = new NpgsqlCommand("insert into siparis (siparisid,musteriid,personelid,kargoid,odemeid,toplamtutar) values (@p1,@p2,@p3,@p4,@p5,@p6)", baglanti);

            eklesiparis.Parameters.AddWithValue("@p1", int.Parse(textBox1.Text));
            eklesiparis.Parameters.AddWithValue("@p2", int.Parse(textBox7.Text));
            eklesiparis.Parameters.AddWithValue("@p3", int.Parse(textBox4.Text));
            eklesiparis.Parameters.AddWithValue("@p4", int.Parse(comboBox1.SelectedValue.ToString()));
            eklesiparis.Parameters.AddWithValue("@p5", int.Parse(comboBox2.SelectedValue.ToString()));
            eklesiparis.Parameters.AddWithValue("@p6", int.Parse(textBox6.Text));
            eklesiparis.ExecuteNonQuery();
            baglanti.Close();
            MessageBox.Show("Siparis ekleme islemi basarili");
            yazdir();
            label10.Visible = true;
            label5.Visible = true;
            label7.Visible = true;
            label8.Visible = true;
            label9.Visible = true;
            textBox3.Visible = true;
            textBox7.Visible = true;
            textBox8.Visible = true;
            comboBox3.Visible = true;
            button1.Visible = true;
            button2.Visible = true;
            siparislistele.Location = new Point(537, 357);
            label11.Visible = false;
            textBox1.Visible = false;
            textBox4.Visible = false;
            textBox6.Visible = false;
            comboBox1.Visible = false;
            comboBox2.Visible = false;
            label1.Visible = false;
            label2.Visible = false;
            label3.Visible = false;
            label4.Visible = false;
            label6.Visible = false;
            siparisekle.Visible = false;
        }
    }
}
