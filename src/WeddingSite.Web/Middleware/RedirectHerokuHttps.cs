using System.Text;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Rewrite;
using Microsoft.Net.Http.Headers;
using System;

namespace WeddingSite.Middleware
{
    // Redirects HTTP requests coming from Heroku's router to HTTPS.
    // Based on https://jaketrent.com/post/https-redirect-node-heroku/ and
    // https://github.com/aspnet/AspNetCore/blob/cc1f23c5f8afb7d2a00405f19811d2372c4fcec2/src/Middleware/Rewrite/src/RedirectToHttpsRule.cs
    public static class RedirectHerokuRequests
    {
        public static void ToHttps(RewriteContext context)
        {
            var request = context.HttpContext.Request;

            if (request.Headers.TryGetValue("x-forwarded-proto", out var forwardedProtocol)
                && forwardedProtocol == "http")
            {
                var newUrl = new StringBuilder()
                    .Append("https://")
                    .Append(new HostString(context.HttpContext.Request.Host.Host))
                    .Append(request.PathBase)
                    .Append(request.Path)
                    .Append(request.QueryString);

                var response = context.HttpContext.Response;
                response.StatusCode = StatusCodes.Status301MovedPermanently;
                context.Result = RuleResult.EndResponse;
                response.Headers[HeaderNames.Location] = newUrl.ToString();
            }
        }
    }
}