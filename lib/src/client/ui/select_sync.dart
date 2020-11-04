part of ui;

class SelectSync extends cl_form.Select {
  SelectSync(cl_app.Application ap, [first]) : super() {
    execute =
        () => ap.serverCall<List>(Routes.sync.reverse([]), null).then((data) {
              data = data.cast<Map>();
              if (first != null) data.insert(0, {'k': first[0], 'v': first[1]});
              return data;
            });
  }
}
