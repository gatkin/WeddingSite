using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using WeddingSite.Models;
using WeddingSite.Core;

namespace WeddingSite.Controllers
{
    public class RsvpController : Controller
    {
        private readonly IGuestService GuestService;

        public RsvpController(IGuestService guestService)
        {
            GuestService = guestService;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IEnumerable<Guest> Guests()
        {
            return GuestService.GetAllGuests();
        }
    }
}
