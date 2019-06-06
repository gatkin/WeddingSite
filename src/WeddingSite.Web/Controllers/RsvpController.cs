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

        public async Task<GuestListResponse> Guests()
        {
            var guests = await GuestService.GetAllGuestsAsync();
            var plusOnes = await GuestService.GetAllPlusOnePairsAsync();

            var guestModels = from guest in guests
                              select new GuestModel{ Id = guest.Id, Name = guest.Name };
            
            var plusOneModels = from pair in plusOnes
                                select new PlusOneModel
                                {
                                    PartnerAName = GetGuestNameById(guests, pair.PartnerAId),
                                    PartnerBName = GetGuestNameById(guests, pair.PartnerBId),
                                };
            
            return new GuestListResponse
            {
                Guests = guestModels,
                PlusOnes = plusOneModels,
            };
        }

        [HttpPost]
        public AttendanceRequest Attendance([FromBody]AttendanceRequest request)
        {
            return request;
        }

        private static string GetGuestNameById(IEnumerable<Guest> guests, string id)
        {
            return guests.Single(guest => guest.Id == id).Name;
        }
    }
}
