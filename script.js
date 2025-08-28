document.addEventListener('DOMContentLoaded', () => {

    const videoWall = document.getElementById('video-wall');
    const prevBtn = document.getElementById('prev-btn');
    const nextBtn = document.getElementById('next-btn');

    let videoData = []; // 将存储所有视频对象 {name, scale}
    let currentPage = 0;
    let videosPerPage = 10;
    // 【关键改动】保留标记，但它的设置时机将改变
    let isHandlingFullscreen = false; 
    let resizeTimer;

    /**
     * 初始化函数
     */
    const init = () => {
        const shuffledList = shuffleArray(videoList);

        videoData = shuffledList.map(name => ({
            name: name,
            scale: Math.random() * 0.6 + 0.5 
        }));
        
        calculateVideosPerPage();
        displayVideos();

        prevBtn.addEventListener('click', () => changePage(-1));
        nextBtn.addEventListener('click', () => changePage(1));
        window.addEventListener('resize', handleResize);
        // 【关键改动】不再需要监听 fullscreenchange 事件
        // document.addEventListener('fullscreenchange', handleFullscreenChange);
    };
    
    const shuffleArray = (array) => {
        const newArray = [...array];
        for (let i = newArray.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [newArray[i], newArray[j]] = [newArray[j], newArray[i]];
        }
        return newArray;
    };

    const calculateVideosPerPage = () => {
        const screenArea = window.innerWidth * window.innerHeight;
        const averageVideoArea = 250 * 180;
        const count = Math.floor(screenArea / averageVideoArea);
        videosPerPage = Math.max(4, Math.min(count, 30));
    };

    const updateNavButtons = () => {
        const totalPages = Math.ceil(videoData.length / videosPerPage);
        prevBtn.disabled = currentPage === 0;
        nextBtn.disabled = currentPage >= totalPages - 1;
    };
    
    const displayVideos = () => {
        videoWall.innerHTML = '';
        const startIndex = currentPage * videosPerPage;
        const videosToShow = videoData.slice(startIndex, startIndex + videosPerPage);

        videosToShow.forEach(videoInfo => {
            const container = document.createElement('div');
            container.className = 'video-container';

            const video = document.createElement('video');
            video.src = `video/${videoInfo.name}`;
            video.autoplay = true;
            video.loop = true;
            video.muted = true;
            video.playsInline = true;

            const filename = document.createElement('div');
            filename.className = 'video-filename';
            filename.textContent = videoInfo.name;

            container.appendChild(video);
            container.appendChild(filename);
            videoWall.appendChild(container);
            
            video.addEventListener('loadedmetadata', () => {
                const nativeWidth = video.videoWidth;
                const nativeHeight = video.videoHeight;
                const scale = videoInfo.scale;
                const baseSize = 250;
                const ratio = nativeWidth / nativeHeight;
                let finalWidth = baseSize * ratio * scale;
                let finalHeight = baseSize * scale;
                const maxHeight = window.innerHeight * 0.85;
                if (finalHeight > maxHeight) {
                    const reductionRatio = maxHeight / finalHeight;
                    finalHeight = maxHeight;
                    finalWidth *= reductionRatio;
                }
                container.style.width = `${finalWidth}px`;
                container.style.height = `${finalHeight}px`;
            });

            // 【关键改动】在这里处理全屏标记的逻辑
            container.addEventListener('click', () => {
                // 1. 立即设置标记，抢在 resize 事件前
                isHandlingFullscreen = true;

                if (document.fullscreenElement) {
                    document.exitFullscreen();
                } else {
                    video.requestFullscreen();
                }
                
                // 2. 无论成功与否，在短暂延迟后都清除标记，以允许正常缩放
                setTimeout(() => {
                    isHandlingFullscreen = false;
                }, 500); // 500毫秒足够浏览器完成切换
            });
        });
        
        updateNavButtons();
    };

    const changePage = (direction) => {
        const totalPages = Math.ceil(videoData.length / videosPerPage);
        const newPage = currentPage + direction;

        if (newPage >= 0 && newPage < totalPages) {
            currentPage = newPage;
            videoWall.style.opacity = '0';
            setTimeout(() => {
                displayVideos();
                videoWall.style.opacity = '1';
            }, 300);
        }
    };
    
    // 【关键改动】不再需要 handleFullscreenChange 函数了
    /*
    const handleFullscreenChange = () => { ... };
    */

    /**
     * 处理窗口大小调整的事件 (现在逻辑是可靠的)
     */
    const handleResize = () => {
        // 这个检查现在可以成功拦截因点击全屏而触发的 resize
        if (isHandlingFullscreen) {
            return;
        }
        
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(() => {
            calculateVideosPerPage();
            const totalPages = Math.ceil(videoData.length / videosPerPage);
            if (currentPage >= totalPages) {
                currentPage = Math.max(0, totalPages - 1);
            }
            displayVideos();
        }, 250);
    };

    // 启动应用
    init();
});