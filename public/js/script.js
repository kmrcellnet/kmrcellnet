$(document).ready(function () {
    let items = [];

    $.getJSON("/data/items.json").done(function (data) {
        items = data;
        loadModalData();
    });

    function parseDate(dateStr) {
        const [day, month, year] = dateStr.split(" ");
        const months = {
            januari: "01",
            februari: "02",
            maret: "03",
            april: "04",
            mei: "05",
            juni: "06",
            juli: "07",
            agustus: "08",
            september: "09",
            oktober: "10",
            november: "11",
            desember: "12"
        };
        return new Date(`${year}-${months[month]}-${day}`);
    }

    function loadModalData(filteredItems = items) {
        const container = $("#modal-item-download-container");
        container.empty();

        filteredItems.sort((a, b) => parseDate(b.date) - parseDate(a.date));

        filteredItems.forEach(item => {
            const itemHtml = `
          <div class="modal-item">
            <div class="modal-item-left">
              <div class="modal-item-left-icon">
                <span>
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="24"
                    height="24"
                    viewBox="0 0 24 24"
                  >
                    <path
                      fill="white"
                      d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8zm4 18H6V4h7v5h5z"
                    />
                  </svg>
                </span>
              </div>
              <div class="modal-item-left-meta">
                <p class="modal-item-left-meta-title">${item.title}</p>
                <p class="modal-item-left-meta-date">${item.date}</p>
              </div>
            </div>
            <div class="modal-item-right">
              <a href="${item.viewLink}" title="view target="_blank">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="22"
                  height="22"
                  viewBox="0 0 24 24"
                  style="margin-top: 5px;"
                >
                  <path
                    fill="white"
                    d="M12 9a3 3 0 0 1 3 3a3 3 0 0 1-3 3a3 3 0 0 1-3-3a3 3 0 0 1 3-3m0-4.5c5 0 9.27 3.11 11 7.5c-1.73 4.39-6 7.5-11 7.5S2.73 16.39 1 12c1.73-4.39 6-7.5 11-7.5M3.18 12a9.821 9.821 0 0 0 17.64 0a9.821 9.821 0 0 0-17.64 0"
                  />
                </svg>
              </a>
              <a href="${item.downloadLink}" title="download target="_blank">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                >
                  <path
                    fill="white"
                    d="m12 16l-5-5l1.4-1.45l2.6 2.6V4h2v8.15l2.6-2.6L17 11zm-6 4q-.825 0-1.412-.587T4 18v-3h2v3h12v-3h2v3q0 .825-.587 1.413T18 20z"
                  />
                </svg>
              </a>
            </div>
          </div>
        `;

            container.append(itemHtml);
        });
    }

    $("#openModalDownload").click(function () {
        loadModalData();
        $("#modal").fadeIn();
        $("body").addClass("no-scroll");
    });

    $(".close").click(function () {
        $("#modal").fadeOut();
        $("body").removeClass("no-scroll");
    });

    $(window).click(function (event) {
        if (event.target.id === "modal") {
            $("#modal").fadeOut();
            $("body").removeClass("no-scroll");
        }
    });

    $("#search").on("input", function () {
        const searchTerm = $(this).val().toLowerCase();

        const filteredItems = items.filter(
            item =>
                item.title.toLowerCase().includes(searchTerm) ||
                item.date.toLowerCase().includes(searchTerm)
        );

        loadModalData(filteredItems);
    });

    // spotify
    const displaySpotify = document.getElementById("spotify");

    const getNowPlaying = async () => {
        try {
            const res = await fetch(
                "https://6t1qitgw-1d0qncop-4gkic1vddz20.aca2-preview.marscode.dev/?access_token=BQCMQj62M9HLVPiJOkHlqM16836LaqJwL6UMk8Gyj9Urt3uh5aaD-lhf3cbGzO-05lTMIocPOLwem1M5h8cUBksRSc88VaNQ_mHuwDxTdV2yXXqiIfAkQ8Ux_076USb2p7Wzz0Rf92GeLDVd5myCSom7CPOmU-H73iCjN9DbhmeMjpe4ITFsJ7ZZqVrCm796NeK6L5Q2da9pHghdTQKer8ITk8wRlE-4F_i10JpRO9-meQ"
            );
            const data = await res.json();

            if (data.isPlaying) {
                displaySpotify.innerHTML = `
            <div class="spotify-content">
                <div class="album-image">
                    <img src=${data.albumImageUrl} alt=""/>
                </div>
                <div class="music-info">
                    <h4>${data.name}</h4>
                    <div class="music-artist">
                    <p>${data.artist[0].name}</p>
                    <span class="wm-spotify">
                                    
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="9"
                            height="9"
                            viewBox="0 0 256 256"
                        >
                            <path
                                fill="#1ed760"
                                d="M128 0C57.308 0 0 57.309 0 128c0 70.696 57.309 128 128 128c70.697 0 128-57.304 128-128C256 57.314 198.697.007 127.998.007zm58.699 184.614c-2.293 3.76-7.215 4.952-10.975 2.644c-30.053-18.357-67.885-22.515-112.44-12.335a7.981 7.981 0 0 1-9.552-6.007a7.968 7.968 0 0 1 6-9.553c48.76-11.14 90.583-6.344 124.323 14.276c3.76 2.308 4.952 7.215 2.644 10.975m15.667-34.853c-2.89 4.695-9.034 6.178-13.726 3.289c-34.406-21.148-86.853-27.273-127.548-14.92c-5.278 1.594-10.852-1.38-12.454-6.649c-1.59-5.278 1.386-10.842 6.655-12.446c46.485-14.106 104.275-7.273 143.787 17.007c4.692 2.89 6.175 9.034 3.286 13.72zm1.345-36.293C162.457 88.964 94.394 86.71 55.007 98.666c-6.325 1.918-13.014-1.653-14.93-7.978c-1.917-6.328 1.65-13.012 7.98-14.935C93.27 62.027 168.434 64.68 215.929 92.876c5.702 3.376 7.566 10.724 4.188 16.405c-3.362 5.69-10.73 7.565-16.4 4.187z"
                            /></svg
                    >
                    <p>Spotify</p>
                    </span>
                    </div>
                </div>
            </div>`;
            } else {
                displaySpotify.innerHTML = "<p>~ No listening to anything</p>";
            }
        } catch (error) {
            console.error("Error fetching now playing data:", error);
        }
    };

    setInterval(() => getNowPlaying(), 10000); //refesh 10s

    getNowPlaying();

    const getCount = async () => {
      const displayCounter = document.getElementById("count");
        try {
            const res = await fetch(
                "https://api-zenn.vercel.app/api/tool/counter/view?q=zenn_my_id_web_counter&secret=cat_lover_c2VjcmV0"
            );
            const data = await res.json();
            const counter = data.data.count;
            displayCounter.innerHTML = counter.toLocaleString();
        } catch (error) {
            console.error("Error fetching counter data:", error);
        }
    }
    getCount();
});
