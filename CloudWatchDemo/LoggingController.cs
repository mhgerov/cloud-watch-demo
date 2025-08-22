using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CloudWatchDemo
{
    [Route("api/[controller]")]
    [ApiController]
    public class LoggingController : ControllerBase
    {
        private readonly ILogger<LoggingController> _iLogger;

        public LoggingController(ILogger<LoggingController> iLogger)
        {
            _iLogger = iLogger;
        }
        [HttpPost("debug")]
        public ActionResult Debug()
        {
            _iLogger.LogDebug("Debug log triggered");
            return Ok();
        }

        [HttpPost("info")]
        public ActionResult Info()
        {
            _iLogger.LogInformation("Info log triggered");
            return Ok();
        }
        
        [HttpPost("error")]
        public ActionResult Error()
        {
            var exception = new MyCustomException();
            throw exception;
            return Ok();
        }

        private class MyCustomException : Exception { }
    }
}
