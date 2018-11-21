import xlwt

def main():
    book= xlwt.Workbook()
    sheet = book.add_sheet('Sheet 1')

    # sheet.write(r, c, <text>)
    sheet.write(0, 0, 'sample')

    book.save('Sample.xls')

if __name__ == '__main__':
    main()
