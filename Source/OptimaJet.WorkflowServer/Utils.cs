using System;
using System.Collections;
using System.Text;

namespace OptimaJet
{
    public static class Utils
    {
        public static string ToDetailedString(this Exception ex)
        {
            var sb = new StringBuilder();
            WriteExceptionDetails(ex,sb,0);
            return sb.ToString();
        }

        private static void WriteExceptionDetails(Exception exception, StringBuilder builderToFill, int level)
        {
            var indent = new string(' ', level);

            if (level > 0)
            {
                builderToFill.AppendLine(indent + "=== INNER EXCEPTION ===");
            }

            Action<string> append = (prop) =>
            {
                var propInfo = exception.GetType().GetProperty(prop);
                if (propInfo != null)
                {
                    var val = propInfo.GetValue(exception);

                    if (val != null)
                    {
                        builderToFill.AppendFormat("{0}{1}: {2}{3}", indent, prop, val.ToString(), Environment.NewLine);
                    }
                }
            };

            append("Message");
            append("HResult");
            append("HelpLink");
            append("Source");
            append("StackTrace");
            append("TargetSite");

            foreach (DictionaryEntry de in exception.Data)
            {
                builderToFill.AppendFormat("{0} {1} = {2}{3}", indent, de.Key, de.Value, Environment.NewLine);
            }

            if (exception.InnerException != null)
            {
                WriteExceptionDetails(exception.InnerException, builderToFill, ++level);
            }
        }
    }
}
