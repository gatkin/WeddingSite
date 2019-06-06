using System.Collections.Generic;

namespace WeddingSite.Models
{
    public class GuestListResponse
    {
        public IEnumerable<GuestModel> Guests { get; set; }

        public IEnumerable<PlusOneModel> PlusOnes { get; set; }
    }

    public class GuestModel
    {
        public string Id { get; set; }

        public string Name { get; set; }
    }

    public class PlusOneModel
    {
        public string PartnerAName { get; set; }

        public string PartnerBName { get; set; }
    }
}