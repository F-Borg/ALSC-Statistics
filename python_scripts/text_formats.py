##########################
# Text Formats
##########################

def add_text_formats(wb):
    fmt = {}
    fmt['arial7']           = wb.add_format({'size':7,'font':'Arial'})
    fmt['arial7bold']       = wb.add_format({'size':7,'font':'Arial','bold':True})
    fmt['arial7boldnum1dec']= wb.add_format({'size':7,'font':'Arial','bold':True,'num_format':'#,##0.0'})
    fmt['arial7num1dec']    = wb.add_format({'size':7,'font':'Arial','num_format':'#,##0.0'})

    fmt['arial8']           = wb.add_format({'size':8,'font':'Arial'})
    fmt['arial8bold']       = wb.add_format({'size':8,'font':'Arial','bold':True})
    fmt['arial8boldnum1dec']= wb.add_format({'size':8,'font':'Arial','bold':True,'num_format':'#,##0.0'})
    fmt['arial8num1dec']    = wb.add_format({'size':8,'font':'Arial','num_format':'#,##0.0'})
    fmt['arial9']           = wb.add_format({'size':9,'font':'Arial'})
    fmt['arial9bold']       = wb.add_format({'size':9,'font':'Arial','bold':True})
    fmt['arial9centre']     = wb.add_format({'size':9,'font':'Arial','align':'centre'})
    fmt['arial9num1dec']    = wb.add_format({'size':9,'font':'Arial','num_format':'#,##0.0'})
    fmt['arial9pct1dec']    = wb.add_format({'size':9,'font':'Arial','num_format':'#,##0.0%'})
    fmt['arial9boldnum1dec']= wb.add_format({'size':9,'font':'Arial','bold':True,'num_format':'#,##0.0'})
    fmt['arial10']          = wb.add_format({'size':10,'font':'Arial'})
    fmt['arial10centre']    = wb.add_format({'size':10,'font':'Arial','align':'centre'})
    fmt['arial10pct1dec']   = wb.add_format({'size':10,'font':'Arial','num_format':'#,##0.0%'})
    fmt['arial10boldcentre']= wb.add_format({'size':10,'font':'Arial','bold':True,'align':'centre'})
    # fmt['arial95']          = wb.add_format({'size':9.5,'font':'Arial'})
    # fmt['arial95bold']      = wb.add_format({'size':9.5,'font':'Arial','bold':True})
    fmt['arial9BIU']        = wb.add_format({'size':9.5,'font':'Arial','bold':True,'italic':True,'underline':True})
    
    fmt['calibri8']                 = wb.add_format({'size':8,'font':'Calibri'})
    fmt['calibri10boldcentre']      = wb.add_format({'size':10,'font':'Calibri','bold':True,'align':'centre'})
    fmt['calibri8boldbottomborder']    = wb.add_format({'size':8,'font':'Calibri','bold':True,'bottom': 1, 'bottom_color': 'black'})

    fmt['heading1']         = wb.add_format({'size':20,'bold':True,'underline':True})
    fmt['bold14centre']     = wb.add_format({'size':14,'bold':True,'align':'centre'})
    fmt['heading1_height']  = 35
    fmt['centre']           = wb.add_format({'align':'centre'})
    return fmt


