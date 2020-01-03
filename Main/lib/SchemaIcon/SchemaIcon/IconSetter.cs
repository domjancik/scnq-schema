using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SchemaIcon
{
    public class IconSetter
    {
        public static Form SetIcon(Form form)
        {
            form.Icon = Properties.Resources.SchemaLogo2_01;
            return form;
        }
    }
}
