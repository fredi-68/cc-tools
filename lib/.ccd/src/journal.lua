JOURNAL_PATH = "/var/log/ccd/"
JOURNAL_LOGFILE = JOURNAL_PATH .. "journal"

function ccd_log_init()
    fs.makeDir(JOURNAL_PATH)
    if fs.exists(JOURNAL_LOGFILE .. ".old") then
        fs.delete(JOURNAL_LOGFILE .. ".old")
    end
    if fs.exists(JOURNAL_LOGFILE) then
        fs.move(JOURNAL_LOGFILE, JOURNAL_LOGFILE .. ".old")
    end
    fs.open(JOURNAL_LOGFILE, "w").close()
    ccd_log("Journaling started.")
end

function ccd_log(s)
    print(s)
    f = fs.open(JOURNAL_LOGFILE, "a")
    f.write(os.clock() .. " " .. s .. "\n")
    f.close()
end