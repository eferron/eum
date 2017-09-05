using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace eumapp
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void RunNetworkCode_Click(object sender, EventArgs e)
        {
            Account account = new Account();
            account.LoadAccountDetail();
        }
    }

    public class Account
    {
        public Account() { }
        public void LoadAccountDetail() {
            try
            {
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create("http://www.google.com");
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                {
                    if (response.StatusCode == HttpStatusCode.OK)
                    {
                        Stream stream = response.GetResponseStream();
                        StreamReader reader = null;
                        if (response.CharacterSet == null)
                        {
                            reader = new StreamReader(stream);
                        }
                        else
                        {
                            reader = new StreamReader(stream, Encoding.GetEncoding(response.CharacterSet));
                        }
                        var content = reader.ReadToEnd();
                    }
                }
                throw new ApplicationException("The application made a call to Google and died");
            }
            catch (Exception ex)
            {
                ILogger log = new Logger();
                log.Debug<string>("My App Exception", ex.Message);
            }
        }
    }

    interface ILogger
    {
        void Debug<T>(string Message, T propertyValue);
    }

    public class Logger : ILogger
    {
        public void Debug<T>(string Message, T propertyValue)
        {
            Console.WriteLine(Message, propertyValue);
        }
    }
}