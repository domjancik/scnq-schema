using System;

namespace Schema
{
    // 1st C# DLL for Schéma
    public static class FileUtils
    {
        public static string SanitizeFileName(string input)
        {
            string invalidChars = System.Text.RegularExpressions.Regex.Escape(new string(System.IO.Path.GetInvalidFileNameChars()));
            string invalidRegStr = string.Format(@"([{0}]*\.+$)|([{0}]+)", invalidChars);

            return System.Text.RegularExpressions.Regex.Replace(input, invalidRegStr, "_");
        }

        public static string SanitizePath(string input)
        {
            string invalidChars = System.Text.RegularExpressions.Regex.Escape(@"\/:*?<>|");
            string invalidRegStr = string.Format(@"([{0}]*\.+$)|([{0}]+)", invalidChars);

            return System.Text.RegularExpressions.Regex.Replace(input, invalidRegStr, "_");
        }
    }
}
