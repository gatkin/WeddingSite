using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Google.Cloud.Firestore;

namespace WeddingSite.Core
{
    public class GuestService : IGuestService
    {
        private readonly FirestoreDb Db;

        public GuestService()
        {
            Db = FirestoreDb.Create("wedding-82625");
        }

        public async Task<IEnumerable<Guest>> GetAllGuestsAsync()
        {
            var collection = Db.Collection("guests");
            var snapshot = await collection.GetSnapshotAsync();

            var guests = snapshot.Documents
                .Select(doc => DocumentToGuest(doc))
                .ToList();

            return guests;
        }

        public async Task<IEnumerable<PlusOnePair>> GetAllPlusOnePairsAsync()
        {
            var collection = Db.Collection("plusOnes");
            var snapshot = await collection.GetSnapshotAsync();

            var plusOnes = snapshot.Documents
                .Select(doc => DocumentToPlusOnePair(doc))
                .ToList();
            
            return plusOnes;
        }

        public async Task UpdateGuestStatusAsync(string guestId, bool isAttending)
        {
            var status = isAttending ? GuestStatus.Attending : GuestStatus.NotAttending;

            await Db.Document($"guests/{guestId}")
                .UpdateAsync(new Dictionary<string, object>{ { "status", status } });
        }

        private static Guest DocumentToGuest(DocumentSnapshot document)
        {
            var dict = document.ToDictionary();
            return new Guest
            {
                Id = document.Id,
                Name = (string)dict["name"],
                Status = (string)dict["status"],
            };
        }

        private static PlusOnePair DocumentToPlusOnePair(DocumentSnapshot document)
        {
            var dict = document.ToDictionary();
            return new PlusOnePair
            {
                PartnerAId = (string)dict["partnerAId"],
                PartnerBId = (string)dict["partnerBId"],
            };
        }
    }
}