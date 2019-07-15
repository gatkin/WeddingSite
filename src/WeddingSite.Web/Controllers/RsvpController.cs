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

        [HttpGet]
        public async Task<IActionResult> Attendance()
        {
            var guests = await GuestService.GetAllGuestsAsync();

            var viewModel = new AttendanceViewModel
            {
                GuestsByStatuses = new []
                {
                    GetGuestsByStatus(guests, GuestStatus.Attending, "Attending Guests"),
                    GetGuestsByStatus(guests, GuestStatus.NotAttending, "Non-Attending Guests"),
                    GetGuestsByStatus(guests, GuestStatus.Unregistered, "Unregistered Guests"),
                }
            };

            return View(viewModel);
        }

        [HttpPost]
        public async Task<ActionResult> Attendance([FromBody]AttendanceRequest request)
        {
            foreach (var guestId in request.GuestIds)
            {
                await GuestService.UpdateGuestStatusAsync(guestId, request.IsAttending);
            }

            return Ok();
        }

        private static string GetFirstName(string fullName)
        {
            return fullName.Split(" ").First();
        }

        private static string GetGuestNameById(IEnumerable<Guest> guests, string id)
        {
            return guests.Single(guest => guest.Id == id).Name;
        }

        private static GuestsByStatus GetGuestsByStatus(
            IEnumerable<Guest> guests,
            string status,
            string statusDisplayText
        )
        {
            var guestsByStatus = from guest in guests
                where guest.Status == status
                orderby GetLastName(guest.Name), GetFirstName(guest.Name)
                select guest.Name;
            
            return new GuestsByStatus
            {
                Status = statusDisplayText,
                GuestNames = guestsByStatus.ToList(),
            };
        }

        private static string GetLastName(string fullName)
        {
            return fullName.Split(" ").ElementAtOrDefault(1) ?? fullName;
        }
    }
}
