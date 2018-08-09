using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using csi.Framework;
using csi.Framework.Utility;
using Newtonsoft.Json;

namespace CSB2018
{
    public partial class Login : System.Web.UI.Page
    {
        string UserAuthenticationMethod;
        string WebServiceSignOnEndpoint;
        string WebServiceSignOnValidationEndpoint;
        int WebServiceRequestTimeout;
        string _userName;
        bool _requirePasswordReset = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            string UserNameLabel = ConfigurationManager.AppSettings["UserNameLabel"];
            string PasswordLabel = ConfigurationManager.AppSettings["PasswordLabel"];
            string UsernameFooter = ConfigurationManager.AppSettings["UserNameFooter"];
            string PasswordFooter = ConfigurationManager.AppSettings["PasswordFooter"];
            string SignInFooter = ConfigurationManager.AppSettings["SignInFooter"];
            string ForgotPasswordText = ConfigurationManager.AppSettings["ForgotPasswordText"];
            string oneTimeValue = Request["OneTimeValue"];

            if (UserNameLabel != null && UserNameLabel.Length > 0)
            {
                inputUsernameLabel.InnerHtml = UserNameLabel;
            }

            if (PasswordLabel != null && PasswordLabel.Length > 0)
            {
                inputPasswordLabel.InnerHtml = PasswordLabel;
            }

            if (UsernameFooter != null && UsernameFooter.Length > 0)
            {
                lblUsernameFooter.InnerHtml = UsernameFooter;
            }
            else
            {
                lblUsernameFooter.Visible = false;
            }

            if (PasswordFooter != null && PasswordFooter.Length > 0)
            {
                lblPasswordFooter.InnerHtml = PasswordFooter;
            }
            else
            {
                lblPasswordFooter.Visible = false;
            }

            if (SignInFooter != null && SignInFooter.Length > 0)
            {
                lblSignInFooter.InnerHtml = SignInFooter;
            }
            else
            {
                lblSignInFooter.Visible = false;
            }

            if (ConfigurationManager.AppSettings["AllowPasswordReset"] == "1")
            {
                if (oneTimeValue != null && oneTimeValue.Length > 0)
                {
                    // Hide password info and change username footer
                    lblUsernameFooter.InnerHtml = string.Format("Please enter your {0} to sign in with your one-time link.", UserNameLabel);
                    lblUsernameFooter.Visible = true;
                    PasswordSpan.Visible = false;
                    PasswordSpan.InnerHtml = "";
                    lblForgotPasswordDiv.InnerHtml = "";
                }
                else
                {
                    if (ForgotPasswordText == null || ForgotPasswordText.Length == 0)
                    {
                        ForgotPasswordText = "Enter your email address to receive a one-time login link.";
                    }

                    // Add forgot password text to the form for use later
                    string scriptText = string.Format("var forgotPasswordText=\"{0}\"; var usernameLabel=\"{1}\";", ForgotPasswordText, UserNameLabel);
                    ClientScript.RegisterClientScriptBlock(this.GetType(), "ScriptVars", scriptText, true);
                }
            }
            else
            {
                lblForgotPasswordDiv.InnerHtml = "";
            }
            

            UserAuthenticationMethod = ConfigurationManager.AppSettings["UserAuthenticationMethod"];
            if (Request["action"] == "logout")
            {
                FormsAuthentication.SignOut();
                Session.Clear();
                ClearCache();
                Response.Redirect(FormsAuthentication.LoginUrl);
            }
            else
            {
                if (!IsPostBack)
                {
                    _userName = Common.get_UserName(Context);
                    if (_userName != "")
                    {
                        FormsAuthentication.RedirectFromLoginPage(_userName, false);
                    }
                    ClearCache();
                    inputUsername.Focus();
                }
                else
                {
                    Hashtable thisAppVariables;
                    _userName = inputUsername.Text;
                    string password = (UserAuthenticationMethod == "WebService" ? token.Value : inputHashedPassword.Value);
                    string forgotPasswordEmail = ForgotPasswordEmail.Value;

                    if (forgotPasswordEmail != null && forgotPasswordEmail.Length > 0 && (password == null || password.Length == 0))
                    {
                        SendForgotPasswordEmail(forgotPasswordEmail);
                    }
                    else
                    {
                        if (AuthenticateUser(_userName, password, oneTimeValue))
                        {
                            if (Context.Session["applicationVariable"] != null)
                            {
                                thisAppVariables = (Hashtable)Context.Session["applicationVariable"];
                                if (thisAppVariables.Contains("UserName"))
                                {
                                    thisAppVariables["UserName"] = _userName;
                                }
                                else
                                {
                                    thisAppVariables.Add("UserName", _userName);
                                }

                                if (thisAppVariables.Contains("RequirePasswordReset"))
                                {
                                    thisAppVariables["RequirePasswordReset"] = _requirePasswordReset;
                                }
                                else
                                {
                                    thisAppVariables.Add("RequirePasswordReset", _requirePasswordReset);
                                }

                                Context.Session["applicationVariable"] = thisAppVariables;
                            }
                            else
                            {
                                thisAppVariables = new Hashtable();
                                thisAppVariables.Add("UserName", _userName);
                                thisAppVariables.Add("RequirePasswordReset", _requirePasswordReset);
                                Context.Session["applicationVariable"] = thisAppVariables;
                            }
                            FormsAuthentication.SetAuthCookie(_userName, false);
                            FormsAuthentication.RedirectFromLoginPage(_userName, false);
                        }
                        else
                        {
                            lblMessage.InnerText = "Username/password combination is invalid.";
                            lblMessage.Attributes["class"] = lblMessage.Attributes["class"].Replace("hidden", "");
                            inputPassword.Text = "";
                        }
                    }
                }
            }
        }

        private bool AuthenticateUser(string username, string password, string oneTimeValue)
        {
            UserAuthenticationMethod = ConfigurationManager.AppSettings["UserAuthenticationMethod"];
            WebServiceRequestTimeout = (ConfigurationManager.AppSettings["WebServiceRequestTimeout"] != null ? Int32.Parse(ConfigurationManager.AppSettings["WebServiceRequestTimeout"]) : 60);
            WebServiceSignOnEndpoint = ConfigurationManager.AppSettings["WebServiceSignOnEndpoint"];
            WebServiceSignOnValidationEndpoint = ConfigurationManager.AppSettings["WebServiceSignOnValidationEndpoint"];

            Data thisData = new Data();
            string sql;
            if (UserAuthenticationMethod == "SQL")
            {
                sql = string.Format("EXEC csb.Login_AuthenticateUser @UserName='{0}', @HashedPassword='{1}', @OneTime='{2}'", username, password, oneTimeValue);
                DataSet ds = thisData.SQL_to_DataSet(sql);

                if (
                    ds != null
                    && ds.Tables.Count > 0
                    && ds.Tables[0].Rows.Count > 0
                    && ds.Tables[0].Columns.Contains("IsAuthenticated")
                    && Boolean.Parse(ds.Tables[0].Rows[0]["IsAuthenticated"].ToString()))
                {
                    DataTable tbl = ds.Tables[0];
                    DataRow row = tbl.Rows[0];
                    _userName = (tbl.Columns.Contains("UserID") ? row["UserID"].ToString() : null);
                    _requirePasswordReset = (tbl.Columns.Contains("RequirePasswordReset") ? Boolean.Parse(row["RequirePasswordReset"].ToString()) : false);
                    return true;
                }
                else return false;
            }
            else if (UserAuthenticationMethod == "WebService")
            {
                try
                {
                    WebRequest req = WebRequest.Create(WebServiceSignOnValidationEndpoint);
                    req.ContentType = "application/json";
                    req.Method = "GET";
                    req.Timeout = WebServiceRequestTimeout;
                    req.Headers.Add("x-access-token", password);

                    //Stream os = req.GetRequestStream();
                    //os.Write(bytes, 0, bytes.length);
                    //os.Close();
                    
                    // Send request and get response
                    HttpWebResponse resp = (HttpWebResponse)req.GetResponse();
                    StreamReader sr = new StreamReader(resp.GetResponseStream());
                    string resultString = sr.ReadToEnd();
                    if (resp.StatusCode == HttpStatusCode.Unauthorized)
                    {
                        return false;
                    }
                    else if (resp.StatusCode == HttpStatusCode.OK)
                    {
                        Hashtable resultHashTable = JsonConvert.DeserializeObject<Hashtable>(resultString);
                        if (resultHashTable.ContainsKey("token"))
                        {
                            sql = string.Format("EXEC csb.Login_AuthenticateUser @UserName='{0}', @HashedPassword='{1}', @Token='{2}', @SubscriberId='{3}'"
                                , username, password, resultHashTable["token"].ToString(), ((Hashtable)resultHashTable["user"])["subscriberId"].ToString());

                            DataSet ds = thisData.SQL_to_DataSet(sql);
                            return (
                                ds != null
                                && ds.Tables.Count > 0
                                && ds.Tables[0].Rows.Count > 0
                                && ds.Tables[0].Columns.Contains("IsAuthenticated")
                                && Boolean.Parse(ds.Tables[0].Rows[0]["IsAuthenticated"].ToString()));
                        }
                    }
                }
                catch
                {
                    return false;
                }
            }
            return false;

        }

        private void SendForgotPasswordEmail (string emailAddress)
        {
            Data thisData = new Data();

            emailAddress = emailAddress.Replace("'", "''").Split(',')[0];
            string sql = string.Format("EXEC csb.Login_SendPasswordReset @EmailAddress='{0}'", emailAddress);
            DataSet ds = thisData.SQL_to_DataSet(sql);

            if (
                ds != null
                && ds.Tables.Count > 0
                && ds.Tables[0].Rows.Count > 0
                && ds.Tables[0].Columns.Contains("Successful")
                && Boolean.Parse(ds.Tables[0].Rows[0]["Successful"].ToString()))
            {
                lblMessage.InnerText = "Email sent successfully. If your email address is on file, you should receive an email shortly.";
                lblMessage.Attributes["class"] = lblMessage.Attributes["class"].Replace("hidden", "").Replace("alert-danger", "alert-success");
            }
            else
            {
                lblMessage.InnerText = "Error sending one-time email!";
                lblMessage.Attributes["class"] = lblMessage.Attributes["class"].Replace("hidden", "");
            }
        }
        private void ClearCache()
        {
            IDictionaryEnumerator CacheEnum = Cache.GetEnumerator();
            while (CacheEnum.MoveNext())
            {
                Cache.Remove(CacheEnum.Key.ToString());
            }
        }
    }
}